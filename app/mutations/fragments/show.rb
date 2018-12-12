module Fragments
  class Cache # CeleryScript Fragment cache, not the other kind.
    def initialize(fragment)
      @fragment               = fragment
      @nodes_by_id            = fragment.nodes.index_by(&:id)
      @arg_set_by_node_id     = fragment.arg_sets.index_by(&:node_id)
      @primitive_by_id        = fragment.primitives.index_by(&:id)
      @pri_pair_by_arg_set_id = fragment.primitive_pairs.group_by(&:arg_set_id)
      @std_pair_by_arg_set_id = fragment.standard_pairs.group_by(&:arg_set_id)
    end

    def get_primitive_pairs(node) # Return Hash<string, number|boolean|string>
      arg_set = @arg_set_by_node_id.fetch(node.id)
      @pri_pair_by_arg_set_id
        .fetch(arg_set.id, [])
        .map do |x|
          [ArgName.cached_by_id(x.arg_name_id).value,
           @primitive_by_id.fetch(x.primitive_id).value]
        end
        .to_h
    end

    # node.arg_set.standard_pairs
    def get_standard_pairs(node)
      arg_set = @arg_set_by_node_id.fetch(node.id)
      @std_pair_by_arg_set_id
        .fetch(arg_set.id, [])
        .map do |x|
          [ArgName.cached_by_id(x.arg_name_id).value,
           @nodes_by_id.fetch(x.node_id)]
        end
    end

    # node.body
    def get_body(node)
      @nodes_by_id.fetch(node.body_id)
    end

    # node.kind.value
    def get_next(node)
      @nodes_by_id.fetch(node.next_id)
    end

    # node.kind
    def kind(node)
      Kind.cached_by_id(node.kind_id)
    end
  end

  class Show < Mutations::Command
    ENTRY    = "internal_entry_point"
    required do
      integer :fragment_id
      model   :device, class: Device
    end

    def execute
      node2cs(cache.get_next(entry_node))
    end

  private

    def node2cs(node)
      standard  = cache.get_standard_pairs(node)
                       .reduce({}) do |acc, (key, value)|
                         acc[key] = node2cs(value)
                         acc
                       end
      result = { kind: cache.kind(node).value,
                 args: cache.get_primitive_pairs(node).merge(standard),
                 body: recurse_into_body(cache.get_body(node)) }
      result.delete(:body) if result[:body].length == 0
      result
    end

    def recurse_into_body(node, body = [])
      unless [Kind.nothing, Kind.entry_point].include?(cache.kind(node))
        body.push(node2cs(node))
        recurse_into_body(cache.get_next(node), body)
      else
        body
      end
    end

    def entry_node
      # .preload(Fragment::EVERYTHING)
      @entry_node ||= nodes.find_by(kind: Kind.cached_by_value(ENTRY))
    end

    def nodes
      @nodes ||= fragment.nodes
    end

    def fragment
      @fragment ||= device.fragments.preload(Fragment::EVERYTHING).find(fragment_id)
    end

    def cache
      @cache ||= Cache.new(fragment)
    end
  end
end
