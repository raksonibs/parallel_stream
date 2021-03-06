defmodule Bench do
  use Benchfella
  Benchfella.start

  setup_all do
    us = average_test_func_call_time
    IO.write("Function call is taking ~#{us} microseconds\n\n")

    if System.get_env("PS_BENCH_OBSERVER") do
      :observer.start()
    end

    { :ok, nil }
  end

  bench "stream" do
    1..10000
    |> Stream.map(&test_func/1)
    |> Stream.run
  end

  bench "parallel_stream" do
    1..10000
    |> ParallelStream.map(&test_func/1)
    |> Stream.run
  end

  defp test_func(_) do
    test_func
  end
  defp test_func do
    :crypto.strong_rand_bytes(600)
  end

  defp average_test_func_call_time do
    (1..10000 |> Enum.reduce(0, fn _, acc ->
      { us, _ } = :timer.tc(&test_func/0)
      acc + us
    end)) / 10000 |> Float.round(2)
  end
end
