class OecdRepresentative::Moderation::BaseController < OecdRepresentative::BaseController
  include ModerateActions

  def moderate
    set_resource_params
    @resources = @resources.where(id: params[:resource_ids])

    if params[:hide_resources].present?
      @resources.each { |resource| hide_resource resource if can?(:hide, resource) }
    elsif params[:ignore_flags].present?
      @resources.each { |resource| resource.ignore_flag if can?(:ignore_flag, resource) }
    end

    redirect_with_query_params_to(action: :index)
  end
end
