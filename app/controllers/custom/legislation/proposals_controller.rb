require_dependency Rails.root.join("app", "controllers", "legislation", "proposals_controller").to_s

class Legislation::ProposalsController < Legislation::BaseController
  private

    def proposal_params
      params.require(:legislation_proposal).permit(:legislation_process_id, :title,
                    :summary, :description, :video_url, :tag_list,
                    image_attributes: image_attributes,
                    documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id])
    end
end
