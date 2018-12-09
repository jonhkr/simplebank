################################################################################
# Copyright 2015 Marcelo Gornstein <marcelog@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
defmodule SimpleBank.LogstashBackendTest do
  use ExUnit.Case

  require Logger

  @backend {SimpleBank.Logger.LogstashBackend, :logstash}
  Logger.add_backend @backend

  setup do
    Logger.configure_backend(@backend, [
      host: "127.0.0.1",
      port: 10001,
      level: :info,
      type: "simplebank"
    ])

    {:ok, socket} = :gen_udp.open 10001, [:binary, {:active, true}]

    on_exit fn ->
      :ok = :gen_udp.close socket
    end

    :ok
  end

  test "can log" do
    Logger.info "hello world", [key1: "field1"]
    json = get_log()

    data = Jason.decode!(json)

    assert data["type"] === "simplebank"
    assert data["message"] === "hello world"

    {:ok, ts} = NaiveDateTime.from_iso8601(data["@timestamp"])

    assert NaiveDateTime.diff(ts, NaiveDateTime.utc_now()) < 100
  end

  test "log µ char" do
    Logger.info "µ"

    json = get_log()

    data = Jason.decode!(json)

    assert data["message"] === "µ"
  end

  test "cant log when minor levels" do
    Logger.debug "hello world", [key1: "field1"]
    :nothing_received = get_log()
  end

  defp get_log do
    receive do
      {:udp, _, _, _, json} -> json
    after 500 -> :nothing_received
    end
  end
end