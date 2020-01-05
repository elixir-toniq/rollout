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

Rollout utilizes [Groot](https://github.com/keathley/groot) for replicating flags
across your cluster. Please look at the groot docs for implementation details.

## Caveats

Rollout relies on your nodes being connected through distributed erlang. If you
are running your application on more than one node and you are not clustering than
your changes won't propogate. You will need to run the command on all nodes but
in practice you'll probably just want to look for an alternative solution.

Flags are *not* maintained in between node restarts. New nodes added to your cluster
will be caught up on the current state. But if you bring up an entirely new cluster
your flags will revert to their default states. You can mitigate this problem
by setting defaults for each flag in your `Application.start/2` callback.

Changes made on one node will take time to replicate to other nodes in the cluster.
But, its a safe operation to run the same command on multiple nodes. Feature flags
will merge cleanly and always default to the latest change seen.

## Should I use this?

If you're already running a clustered application then this should be a reasonable
solution if you need feature flags.

## Future work

I'd like to implement an alternative storage engine for use in non-clustered
environments, preferably using a fast storage engine such as redis. If anyone
wants to submit that PR I'd love to take a look at it.

