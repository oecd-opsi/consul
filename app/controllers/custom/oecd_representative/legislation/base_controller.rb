class OecdRepresentative::Legislation::BaseController < OecdRepresentative::BaseController
  include FeatureFlags

  feature_flag :legislation

  helper_method :namespace

  private

    def namespace
      "oecd_representative"
    end
end
