defmodule Poker do
  @ws ?\s

  # 9      codepoint is 57
  # T -> : codepoint is58
  # J -> ; codepoint is 59
  # Q -> < codepoint is 60
  # K -> = codepoint is 61
  # A -> > codepoint is 62
  def convert_to_sortable(cards) do
    cards
    |> String.replace("T", ":")
    |> String.replace("J", ";")
    |> String.replace("Q", "<")
    |> String.replace("K", "=")
    |> String.replace("A", ">")
  end

  def sort(cards=<<_, _, @ws, _, _, @ws, _, _, @ws, _, _, @ws, _, _>>) do
    cards
    |> convert_to_sortable
    |> String.split
    |> Enum.sort
    |> Enum.join(" ")
  end
  def sort(_), do: raise "incorrect cards"

  def is_straight_flush(cards) do
    case is_flush(cards) do
      {:flush, _} ->
        case is_straight(cards) do
          {:straight, v} -> {:straight_flush, v}
          _ -> {false, nil}
        end
      _ -> {false, nil}
    end
  end

  def is_four_of_a_kind(<<v, _, @ws, v, _, @ws, v, _, @ws, v, _, @ws>> <> _), do: {:four_of_a_kind, v}
  def is_four_of_a_kind(<<_, _, @ws, v, _, @ws, v, _, @ws, v, _, @ws, v, _>>), do: {:four_of_a_kind, v}
  def is_four_of_a_kind(_),do: {false, nil}


  def is_full_house(<<v1, _, @ws, v1, _, @ws, v1, _, @ws, v2, _, @ws, v2, _>>), do: {:full_house, v1}
  def is_full_house(<<v1, _, @ws, v1, _, @ws, v2, _, @ws, v2, _, @ws, v2, _>>), do: {:full_house, v2}
  def is_full_house(_), do: {false, nil}

  def is_flush(<<v1, suit, @ws, v2, suit, @ws, v3, suit, @ws, v4, suit, @ws, v5, suit>>), do: {:flush, <<v5, v4, v3, v2, v1>>}
  def is_flush(_), do: {false, nil}

  def is_straight(<<v1, _, @ws, v2, _, @ws, v3, _, @ws, v4, _, @ws, v5, _>>) do
    if (v2 == v1+1) and (v3 == v1+2) and (v4 == v1+3) and (v5 == v1+4) do
      {:straight, v5}
    else
      {false, nil}
    end
  end
  def is_straight(_), do: {false, nil}

  def is_three_of_a_kind(<<v, _, @ws, v, _, @ws, v, _, @ws>> <> _), do: {:three_of_a_kind, v}
  def is_three_of_a_kind(<<_, _, @ws, _, _, @ws, v, _, @ws, v, _, @ws, v, _>>), do: {:three_of_a_kind, v}
  def is_three_of_a_kind(<<_, _, @ws, v, _, @ws, v, _, @ws, v, _, @ws, _, _>>), do: {:three_of_a_kind, v}
  def is_three_of_a_kind(_), do: {false, nil}

  def is_two_pairs(<<v1, _, @ws, v1, _, @ws, v2, _, @ws, v2, _, @ws, rv, _>>), do: {:two_pairs, <<v2, v1>>, rv}
  def is_two_pairs(<<rv, _, @ws, v1, _, @ws, v1, _, @ws, v2, _, @ws, v2, _>>), do: {:two_pairs, <<v2, v1>>, rv}
  def is_two_pairs(<<v1, _, @ws, v1, _, @ws, rv, _, @ws, v2, _, @ws, v2, _>>), do: {:two_pairs, <<v2, v1>>, rv}
  def is_two_pairs(_),do: {false, nil}

  def is_pair(<<vp, _, @ws, vp, _, @ws, v1, _, @ws, v2, _, @ws, v3, _>>), do: {:pair, vp, <<v3, v2, v1>>}
  def is_pair(<<v1, _, @ws, vp, _, @ws, vp, _, @ws, v2, _, @ws, v3, _>>), do: {:pair, vp, <<v3, v2, v1>>}
  def is_pair(<<v1, _, @ws, v2, _, @ws, vp, _, @ws, vp, _, @ws, v3, _>>), do: {:pair, vp, <<v3, v2, v1>>}
  def is_pair(<<v1, _, @ws, v2, _, @ws, v3, _, @ws, vp, _, @ws, vp, _>>), do: {:pair, vp, <<v3, v2, v1>>}
  def is_pair(<<v1, _, @ws, v2, _, @ws, v3, _, @ws, v4, _, @ws, v5, _>>), do: {:high_card, <<v5, v4, v3, v2, v1>>}

  def compute_cards_rank(cards) do
    cards
    |> sort
    |> compute_cards_rank([
                          :is_straight_flush,
                          :is_four_of_a_kind,
                          :is_full_house,
                          :is_flush,
                          :is_straight,
                          :is_three_of_a_kind,
                          :is_two_pairs,
                          :is_pair])
  end
  def compute_cards_rank(sorted_cards, [rule|rest_rules]) do
    case apply(__MODULE__, rule, [sorted_cards]) do
      {false, nil} ->
        compute_cards_rank(sorted_cards, rest_rules)
      cards_rank ->
        cards_rank
    end
  end
  def compute_cards_rank(_sorted_cards, []), do: raise("Compute Cards Rank Error!")

  defp convert_to_readable(winner_value, _loser_value) when is_number(winner_value) do
    convert_to_readable winner_value
  end
  defp convert_to_readable(winner_cards, loser_cards) do
    value = (String.to_charlist(winner_cards) -- String.to_charlist(loser_cards)) |> List.first
    convert_to_readable(value)
  end
  defp convert_to_readable(value) when is_number(value) do
    case value do
      ?: -> "T"
      ?; -> "Jack"
      ?< -> "Queen"
      ?= -> "King"
      ?> -> "Ace"
      _  -> <<value :: utf8>>
    end
  end
  
  def judge(player_rank1={player1, {cards_type, _}}, player_rank2={player2, {cards_type, _}}) do
    [{_, {_, v1}}, {_, {_, v2}}] = [player_rank1, player_rank2]
    cond do
      v1 >  v2 -> "#{player1} wins.- with #{cards_type}: #{convert_to_readable(v1, v2)}"
      v1 <  v2 -> "#{player2} wins.- with #{cards_type}: #{convert_to_readable(v2, v1)}"
      v1 == v2 -> "Tie."
    end
  end
  def judge({player1, {cards_type, r1, r3}}, {player2, {cards_type, r2, r4}}) do
    case judge({player1, {cards_type, r1}}, {player2, {cards_type, r2}}) do
      "Tie." -> judge({player1, {cards_type, r3}}, {player2, {cards_type, r4}})
      r -> r
    end
  end
  def judge({player1, rank1}, {player2, rank2}) do
    cards_types = [:high_card, :pair, :two_pairs,
                   :three_of_a_kind, :straight,
                   :flush, :full_house,
                   :four_of_a_kind, :straight_flush]

    fetch_cards_type = fn(rank) -> rank |> Tuple.to_list |> List.first end

    compute_cards_type_rank = fn(cards_type) -> Enum.find_index(cards_types, fn(x) -> x == cards_type end) end

    {cards_type1, cards_type2} = {rank1 |> fetch_cards_type.(),
                                  rank2 |> fetch_cards_type.()}

    {cards_rank1, cards_rank2} = {cards_type1 |> compute_cards_type_rank.(),
                                  cards_type2 |> compute_cards_type_rank.()}
    cond do
      cards_rank1 == cards_rank2 -> "Tie."
      cards_rank1 >  cards_rank2 -> "#{player1} wins.- with #{cards_type1}"
      cards_rank1 <  cards_rank2 -> "#{player2} wins.- with #{cards_type2}"
    end
  end

  def main(game) do
    try do
      [[_, black_cards, white_cards]] = Regex.scan(~r/Black: (.{14}) White: (.{14})/, game)
      judge(
        {"Black", black_cards |> sort |> compute_cards_rank},
        {"White", white_cards |> sort |> compute_cards_rank})
    rescue
      _ ->
        raise("Input Error!")
    end
  end
end
