extends RefCounted

func draw(pile: Array, discard: Array, amount: int, random_provider: Object) -> Array:
	var drawn: Array = []
	for _index in amount:
		if pile.is_empty() and not discard.is_empty():
			pile.append_array(random_provider.shuffled(discard))
			discard.clear()
		if pile.is_empty():
			break
		drawn.append(pile.pop_back())
	return drawn

func refresh_hand(player: Object, action_pile: Array, discard_pile: Array, capacity: int, random_provider: Object) -> void:
	var needed := maxi(0, capacity - player.hand.size())
	player.hand.append_array(draw(action_pile, discard_pile, needed, random_provider))
