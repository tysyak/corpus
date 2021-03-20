defmodule CorpusTest do
  use ExUnit.Case
  doctest Corpus

  test "greets the world" do
    assert Corpus.hello() == :world
  end
end
