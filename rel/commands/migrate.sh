#!/bin/sh

release_ctl eval --mfa "SimpleBank.ReleaseTasks.migrate/1" --argv -- "$@"