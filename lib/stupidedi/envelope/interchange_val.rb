module Stupidedi
  module Envelope

    #
    # @see X12.5 3.2.1 Basic Interchange Service Request
    #
    class InterchangeVal
      include Values::SegmentValGroup

      # @return [InterchangeDef]
      attr_reader :definition

      # @return [Array<SegmentVal>]
      attr_reader :header_segment_vals

      # @return [Array<FunctionalGroupVal>]
      attr_reader :functional_group_vals

      # @return [Array<SegmentVal>]
      attr_reader :trailer_segment_vals

      # @return [#segment, #element, #repetition, #component]
      abstract :separators

      def initialize(definition, header_segment_vals, functional_group_vals, trailer_segment_vals)
        @definition, @segment_vals, @functional_group_vals, @trailer_segment_vals =
          definition, header_segment_vals, functional_group_vals, trailer_segment_vals

        @header_segment_vals   = header_segment_vals.map{|x| x.copy(:parent => self) }
        @functional_group_vals = functional_group_vals.map{|x| x.copy(:parent => self) }
        @trailer_segment_vals  = trailer_segment_vals.map{|x| x.copy(:parent => self) }
      end

      # @return [InterchangeVal]
      def copy(changes = {})
        self.class.new \
          changes.fetch(:definition, @definition),
          changes.fetch(:header_segment_vals, @header_segment_vals),
          changes.fetch(:functional_group_vals, @functional_group_vals),
          changes.fetch(:trailer_segment_vals, @trailer_segment_vals)
      end

      def segment_vals
        @header_segment_vals + @trailer_segment_vals
      end

      def empty?
        @header_segment_vals.all(&:empty?) and
        @functional_group_vals.all(&:empty?) and
        @trailer_segment_vals.all(&:empty?)
      end

      def append(val)
        if val.is_a?(FunctionalGroupVal)
          copy(:functional_group_vals => val.snoc(@functional_group_vals))
        else
          if @functional_group_vals.empty?
            copy(:header_segment_vals => val.snoc(@header_segment_vals))
          else
            copy(:trailer_segment_vals => val.snoc(@trailer_segment_vals))
          end
        end
      end

      def prepend(val)
        if val.is_a?(FunctionalGroupVal)
          copy(:functional_group_vals => val.cons(@functional_group_vals))
        else
          if @functional_group_vals.empty?
            copy(:header_segment_vals => val.cons(@header_segment_vals))
          else
            copy(:trailer_segment_vals => val.cons(@trailer_segment_vals))
          end
        end
      end

      # @private
      def pretty_print(q)
        id = @definition.try{|d| "[#{d.id}]" }
        q.text("InterchangeVal#{id}")
        q.group(1, "(", ")") do
          q.breakable ""
          @header_segment_vals.each do |e|
            unless q.current_group.first?
              q.text ", "
              q.breakable
            end
            q.pp e
          end
          @functional_group_vals.each do |e|
            unless q.current_group.first?
              q.text ", "
              q.breakable
            end
            q.pp e
          end
          @trailer_segment_vals.each do |e|
            unless q.current_group.first?
              q.text ", "
              q.breakable
            end
            q.pp e
          end
        end
      end

      # @private
      def ==(other)
        other.definition            == @definition and
        other.header_segment_vals   == @header_segment_vals and
        other.trailer_segment_vals  == @trailer_segment_vals and
        other.functional_group_vals == @functional_group_vals
      end
    end

  end
end
