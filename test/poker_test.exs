defmodule PokerTest do
  use ExUnit.Case

  import Poker.PokerHands

  test "convert cards to sortable format" do
    assert convert_to_sortable("TH AH QH KH JH") == ":H >H <H =H ;H"
  end

  test "sort" do
    assert sort("2H 2D 2S KD 2C") == "2C 2D 2H 2S =D"

    assert_raise RuntimeError, "incorrect cards", fn -> 
      sort("wrong cards")
    end

    assert sort("KS 2H 4C 9D AC") == "2H 4C 9D =S >C"
  end

  test "is straight flush" do
    assert "TH JH QH KH AH" |> sort |> is_straight_flush() == {:straight_flush, ?>}
    assert "TH JH QH KH 2C" |> sort |> is_straight_flush() == {false, nil}
    assert "2H 2D 2S 2C KD" |> sort |> is_straight_flush() == {false, nil}
  end

  test "is four of a kind" do
    assert "2H 2D 2S 2C KD" |> sort |> is_four_of_a_kind() == {:four_of_a_kind, ?2}
    assert "2S KH KS KC KD" |> sort |> is_four_of_a_kind() == {:four_of_a_kind, ?=}
    assert "2S 3H KS KC KD" |> sort |> is_four_of_a_kind() == {false, nil}
  end

  test "is full house" do
    assert "TS QC TC QD QH" |> sort |> is_full_house() == {:full_house, ?<}
    assert "3S 2C 3C 2D 2H" |> sort |> is_full_house() == {:full_house, ?2}
  end

  test "is flush" do
    assert "KC 2C 3C AC QC" |> sort |> is_flush() == {:flush, << ?>, ?=, ?<, ?3, ?2 >>}
  end

  test "is straight" do
    assert "TS JC QD KH AD" |> sort |> is_straight() == {:straight, ?>}
    assert "3S 5C 2D 4H 6D" |> sort |> is_straight() == {:straight, ?6}
  end

  test "is three of a kind" do
    assert "2S 2C 2D 3H 4C" |> sort |> is_three_of_a_kind() == {:three_of_a_kind, ?2}
    assert "2S 3C 4D 4H 4C" |> sort |> is_three_of_a_kind() == {:three_of_a_kind, ?4}
    assert "2S TC TD TH AC" |> sort |> is_three_of_a_kind() == {:three_of_a_kind, ?:}

    assert "2S 2D 3C 3D 4C" |> sort |> is_three_of_a_kind() == {false, nil}
  end

  test "is two pairs" do
    assert "2S 2D 3C 3D 4C" |> sort |> is_two_pairs() == {:two_pairs,<< ?3, ?2 >>, ?4}
    assert "2S 3D 3C 4D 4C" |> sort |> is_two_pairs() == {:two_pairs,<< ?4, ?3 >>, ?2}
    assert "2S 2D 3C 4D 4C" |> sort |> is_two_pairs() == {:two_pairs,<< ?4, ?2 >>, ?3}
  end

  test "is pair" do
    assert "2S 2C 3D 4S 5C" |> sort |> is_pair() == {:pair, ?2, << ?5, ?4, ?3>>}
  end

  test "compute cards rank" do
    assert "TH JH QH KH AH" |> compute_cards_rank() == {:straight_flush, ?>}
    assert "2H 2D 2S 2C KD" |> compute_cards_rank() == {:four_of_a_kind, ?2}
    assert "2S KH KS KC KD" |> compute_cards_rank() == {:four_of_a_kind, ?=}
    assert "TS QC TC QD QH" |> compute_cards_rank() == {:full_house, ?<}
    assert "3S 2C 3C 2D 2H" |> compute_cards_rank() == {:full_house, ?2}
    assert "KC 2C 3C AC QC" |> compute_cards_rank() == {:flush, << ?>, ?=, ?<, ?3, ?2 >>}
    assert "TS JC QD KH AD" |> compute_cards_rank() == {:straight, ?>}
    assert "3S 5C 2D 4H 6D" |> compute_cards_rank() == {:straight, ?6}
    assert "2S 2C 2D 3H 4C" |> compute_cards_rank() == {:three_of_a_kind, ?2}
    assert "2S 3C 4D 4H 4C" |> compute_cards_rank() == {:three_of_a_kind, ?4}
    assert "2S TC TD TH AC" |> compute_cards_rank() == {:three_of_a_kind, ?:}
    assert "2S 2D 3C 3D 4C" |> compute_cards_rank() == {:two_pairs,<< ?3, ?2 >>, ?4}
    assert "2S 3D 3C 4D 4C" |> compute_cards_rank() == {:two_pairs,<< ?4, ?3 >>, ?2}
    assert "2S 2D 3C 4D 4C" |> compute_cards_rank() == {:two_pairs,<< ?4, ?2 >>, ?3}
    assert "2S 2C 3D 4S 5C" |> compute_cards_rank() == {:pair, ?2, << ?5, ?4, ?3 >>}
    assert "2C 3D 4H 5C KS" |> compute_cards_rank() == {:high_card, << ?=, ?5, ?4, ?3, ?2 >>}
  end

  test "judge" do
    assert judge({"Black", {:full_house, ?<}}, {"White", {:full_house, ?<}}) == "Tie."
    assert judge({"Black", {:full_house, ?1}}, {"White", {:full_house, ?<}}) == "White wins.- with full_house: Queen"
    assert judge({"Black", {:high_card, << ?=, ?5, ?4, ?3, ?2 >>}}, {"White", {:high_card, << ?<, ?5, ?4, ?3, ?2 >>}}) == "Black wins.- with high_card: King"

    assert judge({"Black", {:two_pairs,<< ?3, ?2 >>, ?4}}, {"White", {:two_pairs,<< ?5, ?3 >>, ?>}}) == "White wins.- with two_pairs: 5"
    assert judge({"Black", {:two_pairs,<< ?3, ?2 >>, ?4}}, {"White", {:two_pairs,<< ?3, ?2 >>, ?5}}) == "White wins.- with two_pairs: 5"

    assert judge({"Black", {:high_card, << ?=, ?5, ?4, ?3, ?2 >>}}, {"White", {:pair, ?2, << ?5, ?4, ?3 >>}}) == "White wins.- with pair"
  end

  test "main" do
    assert main("Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C AH") == "White wins.- with high_card: Ace"
    assert main("邢星: 2H 3D 5S 9C KD XingXing: 2C 3H 4S 8C AH") == "XingXing wins.- with high_card: Ace"
    assert main("Black: 2H 4S 4C 2D 4H White: 2S 8S AS QS 3S") == "Black wins.- with full_house"
    assert main("Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C KH") == "Black wins.- with high_card: 9"
    assert main("Black: 2H 3D 5S 9C KD White: 2D 3H 5C 9S KH") == "Tie."
   end
end
