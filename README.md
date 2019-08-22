# Rollout

Rollout allows you to flip features quickly and easily. It relies on
distributed erlang and uses LWW-Register and Hybrid-logical clocks
to provide maximum availability. Rollout has no dependency on an external
service such as redis which means rollout feature flags can be used in the
critical path of a request with minimal latency increase.

* [Docs](https://hexdocs.pm/rollout).

## Installation

```elixir
def deps do
  [
    {:rollout, "~> 0.1"}
  ]
end
```

## Usage

Rollout provides a simple api for enabling and disabling feature flags across
your cluster. A feature flag can be any term.

```elixir
# Check if a feature is active
Rollout.active?(:blog_post_comments)
# => false

# Activate the feature
Rollout.activate(:blog_post_comments)

# De-activate the feature
Rollout.deactivate(:blog_post_comments)
```

You can also activate a feature a certain percentage of the time.

```elixir
Rollout.activate_percentage(:blog_post_comments, 20)
```

You can run this function on one node in your cluster and the updates will
be propogated across the system. This means that updates to feature flags may
not be instantaneous across the cluster but under normal conditions should propogate
quickly. This is a tradeoff I've made in order to maintain the low latency when
checking if a flag is enabled.

## How does Rollout work?

Rollout maintains a LWW Register for each flag that has been activated or
deactivated. These Registers use hybrid logical clocks (HLC) for causality
tracking. When a flag is activated or deactivated we update the HLC for that
register and propogate that change across the cluster. When merging registers
across the cluster we always take register with the latest HLC. After merging is
done we store the values for each register into an ets table for fast lookups.

## Caveats

Rollout relies on your nodes being connected through distributed erlang. If you
are running your application on more than one node and you are not clustering than
your changes won't propogate. You will need to run the command on all nodes but
in practice you'll probably just want to look for an alternative solution.

Flags are *not* maintained in between node restarts. New nodes added to your cluster
will be caught up on the current state. But if you bring up an entirely new cluster
your flags will revert to their default states. You can mitigate this problem
by setting defaults for each flag in your `Application.start/2` callback.

Because we're using CRDTs to propogate changes its possible that a change made
on one node will take time to propogate to the other nodes. Its a safe operation
to run the same operation on multiple nodes. When feature flags are merged we
also default to the latest HLC.

## Should I use this?

For now I'd say "No". The functionality works but this repo currently has 0
tests and I'm sure there are edge cases. You should also not cluster your
application for the sole purpose of using this library. If you need this
you'll know it. Otherwise you're better off looking at an alternative solution.

## Future work

I'd like to implement an alternative storage engine for use in non-clustered
environments, preferably using a fast storage engine such as redis. If anyone
wants to submit that PR I'd love to take a look at it.

