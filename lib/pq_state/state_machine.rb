module PQState
  class StateMachine
    def self.build(final_states, *transitions)
      new(final_states, transitions.flatten)
    end

    # Initialises a state machine object.
    #
    # @param final_states [Symbol] The list of final states
    # @param transitions [Transition] The ordered list of state transitions
    #
    def initialize(final_states, transitions)
      @transitions  = transitions
      @final_states = final_states
    end

    # Walk the state transition graph and verify that there is no final states
    # other than the specified ones.
    #
    def validate_transition_graph!
      Validator.new(@transitions, @final_states).check_consistent_state_graph!
    end

    # Walk the state transition graph forward starting from a given PQ state.
    #
    # The graph traversal will stop at the first invalid transition, returning
    # the failed transition 'state_from' value.
    #
    # @param state [Symbol] a valid state
    # @param pq [Pq] A PQ active record object.
    # @return [Symbol] Returns the current machine state.
    #
    def next_state(state, pq)
      loop do
        transition_onwards = available_transition(state, pq)
        break unless transition_onwards
        state = transition_onwards.state_to
      end

      state
    end

    private

    def available_transition(state, pq)
      # Assume only single valid transition exists at point in time -  CHECK
      transitions_permitted(state).find { |t| t.valid?(pq) }
    end

    def transitions_permitted(from_state)
      unless states.include?(from_state)
        raise(ArgumentError, "Cannot find a transition from state '#{from_state}'. Valid states are: #{states}")
      end
      @transitions.select { |t| t.state_from == from_state }
    end

    def states
      @states ||= @transitions.reduce(Set.new) do |acc, t|
        acc + Set.new([t.state_from, t.state_to])
      end
    end
  end
end
