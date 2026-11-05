# 0001. Record architecture decisions

- Status: Accepted
- Date: 2026-10-14

## Context

This repo started as one engineer's dotfiles and was not updated for years. Much of
what it contains (nvm, ruby-install, openssl@1.1, ack, mysql@5.7, Docker Desktop) is
there for reasons nobody wrote down. Modernizing it means deciding what to keep, and
we kept having to rediscover why things were the way they were.

## Decision

We will record significant decisions as short ADRs in `docs/adr/`, one per decision,
using the template in that directory. Decisions are not edited after the fact; a
changed decision gets a new ADR that supersedes the old one.

## Alternatives considered

- **Commit messages and PR descriptions only**: they explain a change, but are hard to
  find later and say nothing about the options we rejected.
- **A single design doc**: grows stale and loses the order in which decisions were made.

## Consequences

A small amount of writing per decision. In return, the reasoning (especially the
rejected alternatives) survives for people who were not in the conversation.
