require "rails_helper"

def commentable_path(comment)
  Rails.application.routes.url_helpers.send(:polymorphic_path, comment.commentable, only_path: true)
end

describe "Admin comments" do
  let(:user) { create(:oecd_representative).user }
  let(:question_comment) { create(:comment, commentable: own_legislation_question) }
  let(:proposal_comment) { create(:comment, commentable: own_legislation_proposal) }
  let(:annotation_comment) do
    create(:legislation_annotation,
      draft_version: create(:legislation_draft_version, process: create(:legislation_process, author: user))
    ).comments.last
  end
  let(:other_comment) { create(:comment) }
  let(:own_process) { create(:legislation_process, author: user, title: "Title1") }
  let(:own_process2) { create(:legislation_process, author: user, title: "Title3") }
  let(:other_process) { create(:legislation_process, title: "Title2") }
  let(:own_legislation_question) { create(:legislation_question, process: own_process) }
  let(:own_legislation_proposal) { create(:legislation_proposal, process: own_process2) }

  let(:citizen) { create(:user) }

  before do
    login_as(user)
  end

  context "Comments listing" do
    scenario "OECD Representative dashboard" do
      question_comment
      other_comment
      proposal_comment
      visit oecd_representative_comments_path

      expect(page).to have_content question_comment.body
      expect(page).not_to have_content other_comment.body
      expect(page).to have_content proposal_comment.body
    end
  end

  context "Moderation" do
    scenario "OECD Representative dashboard" do
      question_comment
      other_comment
      proposal_comment
      Flag.flag(create(:user), question_comment)
      visit oecd_representative_root_path
      within("#side_menu") { click_link I18n.t("admin.menu.comments") }
      within("#side_menu") { click_link I18n.t("admin.menu.comments_all") }

      expect(page).to have_content question_comment.body
      expect(page).not_to have_content other_comment.body
      expect(page).not_to have_content proposal_comment.body
    end

    scenario "Hide", :js do
      visit commentable_path(question_comment)

      within("#comment_#{question_comment.id}") do
        accept_confirm { click_link "Hide" }
        expect(page).to have_css(".comment .faded")
      end

      login_as(citizen)
      visit commentable_path(question_comment)

      expect(page).to have_css(".comment", count: 1)
      expect(page).not_to have_content("This comment has been deleted")
      expect(page).not_to have_content("SPAM")
    end

    scenario "Can not hide own comment" do
      proposal_comment.update!(user: user)

      visit commentable_path(proposal_comment)

      within("#comment_#{proposal_comment.id}") do
        expect(page).not_to have_link("Hide")
        expect(page).not_to have_link("Block author")
      end
    end

    scenario "Visit items with flagged comments" do
      question = create(:legislation_question, process: own_process)
      proposal = create(:legislation_proposal, process: own_process2)
      create(:comment, commentable: question, body: "This is SPAM comment on question", flags_count: 2)
      create(:comment, commentable: proposal, body: "This is SPAM comment on proposal", flags_count: 2)

      visit oecd_representative_moderation_comments_path

      expect(page).to have_content(question.title)
      expect(page).to have_content(proposal.title)
      expect(page).to have_content("This is SPAM comment on question")
      expect(page).to have_content("This is SPAM comment on proposal")

      click_link question.title
      expect(page).to have_content(question.title)
      expect(page).to have_content("This is SPAM comment on question")

      visit oecd_representative_moderation_comments_path

      click_link proposal.title
      expect(page).to have_content(proposal.title)
      expect(page).to have_content("This is SPAM comment on proposal")
    end

    describe "/moderation/ screen" do
      describe "moderate in bulk" do
        describe "When a comment has been selected for moderation" do
          before do
            annotation_comment

            visit oecd_representative_moderation_comments_path
            within(".menu.simple") do
              click_link "All"
            end

            within("#comment_#{annotation_comment.id}") do
              check "comment_#{annotation_comment.id}_check"
            end

            expect(page).not_to have_css("comment_#{annotation_comment.id}")
          end

          scenario "Hide the comment" do
            click_on "Hide comments"
            expect(page).not_to have_css("comment_#{annotation_comment.id}")
            expect(annotation_comment.reload).to be_hidden
            expect(annotation_comment.user).not_to be_hidden
          end

          scenario "Ignore the comment" do
            click_on "Mark as viewed"
            expect(page).not_to have_css("comment_#{annotation_comment.id}")
            expect(annotation_comment.reload).to be_ignored_flag
            expect(annotation_comment.reload).not_to be_hidden
            expect(annotation_comment.user).not_to be_hidden
          end
        end

        scenario "select all/none", :js do
          proposal_comment
          question_comment

          visit oecd_representative_moderation_comments_path

          within(".js-check") { click_on "All" }

          expect(all("input[type=checkbox]")).to all(be_checked)

          within(".js-check") { click_on "None" }

          all("input[type=checkbox]").each do |checkbox|
            expect(checkbox).not_to be_checked
          end
        end

        scenario "remembering page, filter and order" do
          stub_const("#{ModerateActions}::PER_PAGE", 2)
          proposal_comment
          question_comment

          visit oecd_representative_moderation_comments_path(filter: "all", page: "2", order: "newest")

          click_on "Mark as viewed"

          expect(page).to have_selector(".js-order-selector[data-order='newest']")

          expect(current_url).to include("filter=all")
          expect(current_url).to include("page=2")
          expect(current_url).to include("order=newest")
        end
      end

      scenario "Current filter is properly highlighted" do
        visit oecd_representative_moderation_comments_path
        expect(page).not_to have_link("Pending")
        expect(page).to have_link("All")
        expect(page).to have_link("Marked as viewed")

        visit oecd_representative_moderation_comments_path(filter: "all")
        within(".menu.simple") do
          expect(page).not_to have_link("All")
          expect(page).to have_link("Pending")
          expect(page).to have_link("Marked as viewed")
        end

        visit oecd_representative_moderation_comments_path(filter: "pending_flag_review")
        within(".menu.simple") do
          expect(page).to have_link("All")
          expect(page).not_to have_link("Pending")
          expect(page).to have_link("Marked as viewed")
        end

        visit oecd_representative_moderation_comments_path(filter: "with_ignored_flag")
        within(".menu.simple") do
          expect(page).to have_link("All")
          expect(page).to have_link("Pending")
          expect(page).not_to have_link("Marked as viewed")
        end
      end

      scenario "Filtering comments" do
        other_comment
        annotation_comment
        Flag.flag(create(:user), annotation_comment)
        create(:comment, commentable: own_legislation_question, body: "Regular comment")
        create(:comment, :flagged, commentable: own_legislation_question, body: "Pending comment")
        create(:comment, :hidden, commentable: own_legislation_proposal, body: "Hidden comment")
        create(:comment, :flagged, :with_ignored_flag, commentable: own_legislation_question, body: "Ignored comment")

        visit oecd_representative_moderation_comments_path(filter: "all")
        expect(page).to have_content("Regular comment")
        expect(page).to have_content("Pending comment")
        expect(page).not_to have_content("Hidden comment")
        expect(page).to have_content("Ignored comment")
        expect(page).to have_content(annotation_comment.body)
        expect(page).not_to have_content(other_comment.body)

        visit oecd_representative_moderation_comments_path(filter: "pending_flag_review")
        expect(page).not_to have_content("Regular comment")
        expect(page).to have_content("Pending comment")
        expect(page).not_to have_content("Hidden comment")
        expect(page).not_to have_content("Ignored comment")
        expect(page).to have_content(annotation_comment.body)
        expect(page).not_to have_content(other_comment.body)

        visit oecd_representative_moderation_comments_path(filter: "with_ignored_flag")
        expect(page).not_to have_content("Regular comment")
        expect(page).not_to have_content("Pending comment")
        expect(page).not_to have_content("Hidden comment")
        expect(page).to have_content("Ignored comment")
        expect(page).not_to have_content(annotation_comment.body)
        expect(page).not_to have_content(other_comment.body)
      end

      scenario "sorting comments" do
        flagged_comment = create(:comment,
                                 commentable: own_legislation_question,
                                 body: "Flagged comment",
                                 created_at: Time.current - 1.day,
                                 flags_count: 5)
        flagged_new_comment = create(:comment,
                                     body: "Flagged new comment",
                                     commentable: own_legislation_proposal,
                                     created_at: Time.current - 12.hours,
                                     flags_count: 3)
        newer_comment = create(:comment,
                               commentable: own_legislation_proposal,
                               body: "Newer comment",
                               created_at: Time.current)

        visit oecd_representative_moderation_comments_path(order: "newest")

        expect(flagged_new_comment.body).to appear_before(flagged_comment.body)

        visit oecd_representative_moderation_comments_path(order: "flags")

        expect(flagged_comment.body).to appear_before(flagged_new_comment.body)

        visit oecd_representative_moderation_comments_path(filter: "all", order: "newest")

        expect(newer_comment.body).to appear_before(flagged_new_comment.body)
        expect(flagged_new_comment.body).to appear_before(flagged_comment.body)

        visit oecd_representative_moderation_comments_path(filter: "all", order: "flags")

        expect(flagged_comment.body).to appear_before(flagged_new_comment.body)
        expect(flagged_new_comment.body).to appear_before(newer_comment.body)
      end
    end
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
