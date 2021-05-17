require "rails_helper"

describe "Admin comments" do
  let(:user) { create(:oecd_representative).user }
  let(:question_comment) { create(:comment, commentable: create(:legislation_question, process: own_process)) }
  let(:proposal_comment) { create(:comment, commentable: create(:legislation_question, process: own_process2)) }
  let(:annotation_comment) do
    create(:legislation_annotation,
      draft_version: create(:legislation_draft_version, process: create(:legislation_process, author: user))
    ).comments.last
  end
  let(:other_comment) { create(:comment) }
  let(:own_process) { create(:legislation_process, author: user, title: "Title1") }
  let(:own_process2) { create(:legislation_process, author: user, title: "Title3") }
  let(:other_process) { create(:legislation_process, title: "Title2") }

  before do
    login_as(user)
  end

  scenario "Index - list comments from own processes" do
    question_comment
    proposal_comment
    annotation_comment
    other_comment
    visit oecd_representative_root_path
    within("#side_menu") { click_link I18n.t("admin.menu.comments") }
    within("#side_menu") { click_link I18n.t("admin.menu.comments_all") }

    expect(page).to have_content question_comment.body
    expect(page).not_to have_content other_comment.body
    expect(page).to have_content proposal_comment.body
    expect(page).to have_content annotation_comment.body
  end

  scenario "To export - lists all processes created by user" do
    own_process
    own_process2
    other_process

    visit oecd_representative_root_path
    within("#side_menu") { click_link I18n.t("admin.menu.comments") }
    within("#side_menu") { click_link I18n.t("admin.menu.comments_to_export") }

    expect(page).to have_content own_process.title
    expect(page).not_to have_content other_process.title
    expect(page).to have_content own_process2.title
  end
end
