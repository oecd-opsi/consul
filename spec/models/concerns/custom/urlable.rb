require "spec_helper"

shared_examples "urlable" do
  let(:urlable) { create(model_name(described_class)) }

  describe "build_url_for" do
    describe "when no resource given for URL" do
      it "generates a correct URL" do
        expect(urlable.build_url_for(:root_url, nil)).to eq("http://#{ENV["SERVER_NAME"]}/")
      end
    end

    describe "when resource given for URL" do
      it "generates a correct resource URL" do
        resource = create(:legislation_process)
        expect(urlable.build_url_for(:legislation_process_url, resource))
          .to eq("http://#{ENV["SERVER_NAME"]}/engagement/processes/#{resource.id}")
      end
    end

    describe "when resource and options given for URL" do
      it "generates a correct resource URL with param" do
        resource = create(:legislation_process)
        expect(urlable.build_url_for(:legislation_process_url, resource, { option_1: 1 }))
          .to eq("http://#{ENV["SERVER_NAME"]}/engagement/processes/#{resource.id}?option_1=1")
      end
    end
  end
end
