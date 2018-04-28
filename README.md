# Poketh
Poketh Contracts, Info, and Utilities

## What is it?

Poketh is a non-fungible derivation of ERC 891, a mineable token proposal.

## What does it do?

Poketh works as a collectible platform. It is able to store data pointing at descriptions of the items and keep track of the balances. In order to acquire the collectibles users may be required to pay a fee.

## Scarcity

Poketh's implementation of ERC 891 uses a rarity with binomial distribution `R ~ Bi(52,0.5)`. The rarity is used to handle relative rarity between item tiers. Additionally it is possible to adjust general difficulty with a difficulty mask between 0 and 12 bits.

<html>
  <img src="https://imgur.com/dT3KEMa.png">  
</html>

The blue section of 12 bits is the adjustable difficulty mask. The red section is the rarity mask. Finally, the green section can be used as a selector for items with the same level of rarity.
