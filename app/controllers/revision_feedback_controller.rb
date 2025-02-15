# frozen_string_literal: true

require_dependency "#{Rails.root}/lib/revision_feedback_service"
require_dependency "#{Rails.root}/lib/importers/revision_score_importer"

class RevisionFeedbackController < ApplicationController
  def index
    set_latest_revision_id
    return if @rev_id.nil?
    liftwing_data = RevisionScoreImporter.new.fetch_liftwing_data_for_revision_id(@rev_id)
    @feedback = RevisionFeedbackService.new(liftwing_data[:features]).feedback
    @user_feedback = Assignment.find(params['assignment_id']).assignment_suggestions
    @rating = liftwing_data[:rating]
  end

  private

  def set_latest_revision_id
    query = { prop: 'revisions', titles: params['title'], rvprop: 'ids' }
    @wiki = Wiki.find_by(language: 'en', project: 'wikipedia')
    response = WikiApi.new(@wiki).query(query)
    page = response.data['pages']
    # The Page ID is the only key in the response
    page_id = page.keys[0]
    revisions = page.dig(page_id, 'revisions')

    # The API sends a response with the id of the last revision
    @rev_id = revisions[0]['revid'] if revisions.present?
  end
end
