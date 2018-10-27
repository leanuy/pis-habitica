# frozen_string_literal: true

class Me::GroupsController < Me::ApplicationController
  before_action :set_group, only: %i[add_habits show view_habits]
  before_action :create_habit, only: %i[add_habits]

  # GET /me/groups
  def index
    groups = current_user.groups
    render json: GroupSerializer.new(groups).serialized_json
  end

  # GET /me/group/id
  def show
    render json: GroupSerializer.new(@group).serialized_json, status: :ok
  end

  # POST /me/groups/id/habits
  def add_habits
    unless @group.membership.find_by!(user_id: current_user.id).admin?
      raise Error::CustomError.new(I18n.t(:unauthorized), '401', I18n.t('errors.messages.not_admin'))
    end

    habit_params = params[:data][:attributes]
    type_ids_params = params[:data][:relationships][:types]

    # At least one type
    if type_ids_params[0].blank?
      raise Error::CustomError.new(I18n.t('bad_request'), :bad_request, I18n.t('errors.messages.typeless_habit'))
    end

    type_ids = []
    type_ids_params.each { |type| type_ids << type[:data][:id] }

    # Type does not exist
    individual_types = Type.find(type_ids)

    habit = GroupHabit.new(
      group_id: params[:id],
      name: habit_params[:name],
      description: habit_params[:description],
      difficulty: habit_params[:difficulty],
      frequency: habit_params[:frequency],
      negative: habit_params[:negative],
      privacy: 1
    )

    habit.save!

    individual_types.each do |type|
      GroupHabitHasType.create(habit_id: habit.id, type_id: type.id)
    end
    render json: GroupHabitSerializer.new(habit).serialized_json, status: :created
  end

  # GET /me/groups/id/habits
  def view_habits
    habits = @group.group_habits
    render json: GroupHabitSerializer.new(habits).serialized_json, status: :created
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    # Se busca solo en los habitos individuales del usuario logueado.
    @group = current_user.groups.find_by!(id: params[:id])
  end

  def create_habit
    params.require(:data).require(:attributes).require(%i[name frequency difficulty])
    # Esto no controla que types sea un array ni que sea no vacio, esa verificacion se hace internamente en creates.
    params.require(:data).require(:relationships).require(:types)
  end

  # Only allow a trusted parameter 'white list' through.
  def habit_params
    params.require(:habit).permit(:group_id, :name, :frequency, :difficulty)
  end
end
