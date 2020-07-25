# frozen_string_literal: true

class CompetitionMedium < ApplicationRecord
  self.table_name = "CompetitionsMedia"
  # Work around the fact that the CompetitionsMedia has a type field.
  #  https://github.com/thewca/worldcubeassociation.org/issues/91#issuecomment-170194667
  self.inheritance_column = :_type_disabled

  belongs_to :competition, foreign_key: "competitionId"
  validates :competition, presence: true

  enum status: { accepted: "accepted", pending: "pending" }
  validates :status, presence: true

  enum type: { report: "report", article: "article", multimedia: "multimedia" }
  validates :type, presence: true
  # TODO: This is a port of the useful *_i18n method from
  # https://github.com/zmbacker/enum_help.
  # https://github.com/thewca/worldcubeassociation.org/issues/2070
  # tracks adding this gem to our codebase.
  def self.types_i18n
    self.types.keys.map { |k| [k, k.titleize] }.to_h
  end

  scope :belongs_to_region, lambda { |region_id|
    joins(competition: [:country]).where(
      "countryId = :region_id OR Countries.continentId = :region_id", region_id: region_id
    )
  }

  before_save :set_timestamp_decided
  private def set_timestamp_decided
    if status_change && status == "accepted"
      self.timestampDecided = Time.now
    end
  end
end
