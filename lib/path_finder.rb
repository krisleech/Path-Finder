# PathFinder

# Usage:
# path_finder :column => 'path', :uid => 'to_param', :deliminator => '/'

module PathFinder

    
  def path_finder(options = {})
    raise "Options for path_finder must be a Hash" unless options.is_a? Hash
    options.each do |key, value|
      unless [:column, :uid, :deliminator].include? key
        raise "Unknown option for path_finder: #{key.inspect} => #{value.inspect}."
      end
    end

    send :include, InstanceMethods
    send :extend, ClassMethods

    options = {
            :column => 'path',
            :uid => 'to_param',
            :deliminator => '/'
          }.merge(options)

    # Create class attributes for options and set defaults
    self.cattr_accessor :path_finder_column
    self.path_finder_column = options[:column] #|| 'path'

    self.cattr_accessor :path_finder_uid
    self.path_finder_uid = options[:uid] #|| 'to_param'

    self.cattr_accessor :path_finder_deliminator
    self.path_finder_deliminator = options[:deliminator] #|| '/'

    before_validation_on_create :set_path
    validates_presence_of self.path_finder_column.to_sym

    if options[:set_depth]
      # add before_save to set depth column
    end

  end # end path_finder


  module ClassMethods
    def path_finder_added?
      true
    end

    # Recalculate all paths for given collection
    def recreate_paths!(collection = nil)
      raise 'No collection given' unless collection.is_a? Array
      collection.each do |obj|
        obj.recreate_path!
        self.recreate_paths!(obj.children) unless obj.children.empty?
      end
    end
  end

  module InstanceMethods
    # Note: self is an instance of "ActiveRecord"


    # FIXME: private
    # before_validation_on_create
    def set_path
      return unless self.send(self.class.path_finder_column).blank?
      unless self.root?
        self.send(self.class.path_finder_column + '=', [self.parent.send(self.class.path_finder_column), self.send(self.class.path_finder_uid)].join(self.class.path_finder_deliminator).gsub('//', '/'))
      else
        self.send(self.class.path_finder_column + '=', self.send(self.class.path_finder_uid))
      end
    end

    def path_array
      unless self.send(self.class.path_finder_column).blank?
        self.send(self.class.path_finder_column.split(self.class.path_finder_deliminator))
      else
        if new_record? && parent
          parent.path_array + [self.send(self.class.path_finder_uid)]
        else
          [] # this should not be possible (test required)
        end
      end
    end

    def leaf?
      children.empty?
    end

    def node?
      !leaf?
    end

    def root?
      parent_id.nil?
    end

    # return a breadcrumb for any attribute
    def path_text(attribute = 'name', join = ' | ')
      ancestors.collect { |item| item.send(attribute) }.join(join)
    end

    def self_and_descendants
      descendants + [self]
    end

    def descendants
      children.map(&:descendants).flatten + children
    end

    def recreate_path!
      set_path
      save!
    end

    # Call method for ancestors, stop if we get an non-nil answer
    def send_down(*args)
      result = self.send(*args)
      if result.nil? && !self.root?
        result = self.parent.send_down(*args)
      end
      result
    end

    # Call method on all children
    def send_up(*args)
      return if children.empty?
      children.each do | child |
        child.send_up(*args)
      end
    end

    # ALTERNATIVE
    #   def self_and_descendants
    #    self.class.find(:all, :conditions => ['path LIKE ?', self.path + '%'])
    #  end
    #
    #
    #  def descendants
    #    self_and_all_children.reject { |c| c.id == self.id }
    #  end
    #
  end
end

ActiveRecord::Base.send :extend, PathFinder
