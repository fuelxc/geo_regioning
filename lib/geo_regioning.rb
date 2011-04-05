# GeoRegioning
%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

#Make the models happy
class GeoRegioning
  @@config = {}

  def self.config=(config)
    @@config = config
  end

  def self.config
    @@config
  end
end

#use the real class if the base isn't a table of its own
module ActiveRecord
  module Associations
    class AssociationProxy
      protected
      def set_belongs_to_association_for(record)
        if @reflection.options[:as]
          record["#{@reflection.options[:as]}_id"]   = @owner.id unless @owner.new_record?
          record["#{@reflection.options[:as]}_type"] = @owner.class.base_class.table_exists? ? @owner.class.base_class.name.to_s : @owner.class.name.to_s
        else
          unless @owner.new_record?
            primary_key = @reflection.options[:primary_key] || :id
            record[@reflection.primary_key_name] = @owner.send(primary_key)
          end
        end
      end
    end

    class HasManyAssociation < AssociationCollection #:nodoc:
      protected
        def construct_sql
          case
            when @reflection.options[:finder_sql]
              @finder_sql = interpolate_sql(@reflection.options[:finder_sql])

            when @reflection.options[:as]
              @finder_sql =
                "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
                "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.table_exists? ? @owner.class.base_class.name.to_s : @owner.class.name.to_s)}"
              @finder_sql << " AND (#{conditions})" if conditions

            else
              @finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
              @finder_sql << " AND (#{conditions})" if conditions
          end

          if @reflection.options[:counter_sql]
            @counter_sql = interpolate_sql(@reflection.options[:counter_sql])
          elsif @reflection.options[:finder_sql]
            # replace the SELECT clause with COUNT(*), preserving any hints within /* ... */
            @reflection.options[:counter_sql] = @reflection.options[:finder_sql].sub(/SELECT (\/\*.*?\*\/ )?(.*)\bFROM\b/im) { "SELECT #{$1}COUNT(*) FROM" }
            @counter_sql = interpolate_sql(@reflection.options[:counter_sql])
          else
            @counter_sql = @finder_sql
          end
        end
    end

    class HasManyThroughAssociation < HasManyAssociation #:nodoc:
      protected
        # Construct attributes for associate pointing to owner.
        def construct_owner_attributes(reflection)
          if as = reflection.options[:as]
            { "#{as}_id" => @owner.id,
              "#{as}_type" => @owner.class.base_class.table_exists? ? @owner.class.base_class.name.to_s : @owner.class.name.to_s }
          else
            { reflection.primary_key_name => @owner.id }
          end
        end

        # Construct attributes for :through pointing to owner and associate.
        def construct_join_attributes(associate)
          # TODO: revist this to allow it for deletion, supposing dependent option is supported
          raise ActiveRecord::HasManyThroughCantAssociateThroughHasOneOrManyReflection.new(@owner, @reflection) if [:has_one, :has_many].include?(@reflection.source_reflection.macro)
          join_attributes = construct_owner_attributes(@reflection.through_reflection).merge(@reflection.source_reflection.primary_key_name => associate.id)
          if @reflection.options[:source_type]
            join_attributes.merge!(@reflection.source_reflection.options[:foreign_type] => associate.class.base_class.table_exists? ? associate.class.base_class.name.to_s : associate.class.name.to_s)
          end
          join_attributes
        end

        # Associate attributes pointing to owner, quoted.
        def construct_quoted_owner_attributes(reflection)
          if as = reflection.options[:as]
            { "#{as}_id" => owner_quoted_id,
              "#{as}_type" => reflection.klass.quote_value(
                @owner.class.base_class.table_exists? ? @owner.class.base_class.name.to_s : @owner.class.name.to_s,
                reflection.klass.columns_hash["#{as}_type"]) }
          elsif reflection.macro == :belongs_to
            { reflection.klass.primary_key => @owner[reflection.primary_key_name] }
          else
            { reflection.primary_key_name => owner_quoted_id }
          end
        end
    end

    class BelongsToPolymorphicAssociation < AssociationProxy #:nodoc:
      def replace(record)
        if record.nil?
          @target = @owner[@reflection.primary_key_name] = @owner[@reflection.options[:foreign_type]] = nil
        else
          @target = (AssociationProxy === record ? record.target : record)
          @owner[@reflection.primary_key_name] = record_id(record)
          @owner[@reflection.options[:foreign_type]] = record.class.base_class.table_exists? ? record.class.base_class.name.to_s : record.class.name.to_s
          @updated = true
        end

        set_inverse_instance(record, @owner)
        loaded
        record
      end
    end

    class HasOneAssociation < BelongsToAssociation #:nodoc:
      private
        def construct_sql
          case
            when @reflection.options[:as]
              @finder_sql =
                "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_id = #{owner_quoted_id} AND " +
                "#{@reflection.quoted_table_name}.#{@reflection.options[:as]}_type = #{@owner.class.quote_value(@owner.class.base_class.table_exists? ? @owner.class.base_class.name.to_s : @owner.class.name.to_s)}"
            else
              @finder_sql = "#{@reflection.quoted_table_name}.#{@reflection.primary_key_name} = #{owner_quoted_id}"
          end
          @finder_sql << " AND (#{conditions})" if conditions
        end
    end
  end

  module AutosaveAssociation
    def save_belongs_to_association(reflection)
      if (association = association_instance_get(reflection.name)) && !association.destroyed?
        autosave = reflection.options[:autosave]
        if autosave && association.marked_for_destruction?
          association.destroy
        elsif autosave != false
          saved = association.save(!autosave) if association.new_record? || autosave

          if association.updated?
            association_id = association.send(reflection.options[:primary_key] || :id)
            self[reflection.primary_key_name] = association_id
            # TODO: Removing this code doesn't seem to matter…  That is because it is duplication of the BelongsToPolymorphicAssociation < AssociationProxy
            if reflection.options[:polymorphic]
              self[reflection.options[:foreign_type]] = association.class.base_class.table_exists? ? association.class.base_class.name.to_s : association.class.name.to_s
            end
          end
          saved if autosave
        end
      end
    end
  end
end
