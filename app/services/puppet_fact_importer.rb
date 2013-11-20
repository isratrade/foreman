class PuppetFactImporter
  delegate :logger, :to => :Rails
  attr_reader :counters

  def initialize(system, facts = {})
    @system     = system
    @facts    = normalize(facts)
    @counters = {}
  end

  # expect a facts hash
  def import!
    delete_removed_facts
    add_new_facts
    update_facts

    logger.info("Import facts for '#{system}' completed. Added: #{counters[:added]}, Updated: #{counters[:updated]}, Deleted #{counters[:deleted]} facts")
  end

  private
  attr_reader :system, :facts

  def delete_removed_facts
    to_delete = system.fact_values.joins(:fact_name).where('fact_names.name NOT IN (?)', facts.keys)
    @counters[:deleted] = to_delete.size
    # N+1 DELETE SQL, but this would allow us to use callbacks (e.g. auditing) when deleting.
    to_delete.destroy_all

    @db_facts           = nil
    logger.debug("Merging facts for '#{system}': deleted #{counters[:deleted]} facts")
  end

  def add_new_facts
    fact_names      = FactName.maximum(:id, :group => 'name')
    facts_to_create = facts.keys - db_facts.keys
    # if the system does not exists yet, we don't have an system_id to use the fact_values table.
    method          = system.new_record? ? :build : :create!
    facts_to_create.each do |name|
      system.fact_values.send(method, :value => facts[name],
                            :fact_name_id  => fact_names[name] || FactName.create!(:name => name).id)
    end

    @counters[:added] = facts_to_create.size
    logger.debug("Merging facts for '#{system}': added #{@counters[:added]} facts")
  end

  def update_facts
    facts_to_update = []
    db_facts.each { |name, fv| facts_to_update << [facts[name], fv] if fv.value != facts[name] }

    @counters[:updated] = facts_to_update.size
    return logger.debug("No facts update required for #{system}") if facts_to_update.empty?

    logger.debug("Merging facts for '#{system}': updated #{@counters[:updated]} facts")

    facts_to_update.each do |new_value, fv|
      fv.update_attribute(:value, new_value)
    end
  end

  def normalize(facts)
    facts.keep_if { |k, v| v.present? && v.is_a?(String) }
  end

  def db_facts
    @db_facts ||= system.fact_values.includes(:fact_name).index_by(&:name)
  end

end