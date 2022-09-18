[中文](./README.cn.md)|[English]

## Minetest:Education Edit

Minetest:Education Edit is an open source interactive educational application based on [Minetest][Minetest] (an open source voxel game engine).

### What's Minetest

[Minetest][minetest]'s concept of "[voxels](https://en.wikipedia.org/wiki/Voxel)" is similar to building blocks (like LEGO blocks). In the interactive world you can use "Blocks" build houses, make tools, and unlike expensive Lego blocks, you can walk around your creations and experience the "new worlds" you've created.

![blocks](imgs/numerica.png) ![sun rise](imgs/sunrise.jpg)

In the interactive world you can build houses, farms, cities, tools and many other incredibly creative things out of material "blocks". For example, metal ore is mined, carved into ingots, used to make pickaxes or other objects of different tools, which are then used to build buildings, or any other structure you can imagine. And unlike expensive LEGO bricks, you can walk around your creations and experience the new world you've created. For example, you can build and use ladders, you can fire sand into glass blocks and make them into windows through which you can watch the square sun rise in the world of Minetest from your porch.

> [Wikipedia](https://en.wikipedia.org/wiki/Minetest): Minetest has been used in educational environments to teach subjects such as mathematics, programming, and earth sciences.
>
> * In 2017 in France, Minetest was used to teach calculus and trigonometry.
> * At Federal University of Santa Catarina in Brazil, Minetest was used to teach programming in a variant called MineScratch.
> * In 2018, for Laboratory Education and Apprenticeships (EDA) at the Paris Descartes University, Minetest was used to teach life and earth sciences to year 6 students who could not observe some phenomena in person but could experience them in the Minetest virtual world.

### What's Minetest:Education Edit

Allowing children to play in the game world does not serve any educational purpose. The brainless gameplay of children in the game world is completely unexpected: jumping from a height to commit suicide (the child calls it bungee jumping), after being resurrected, running again... This can be a lot of fun.

Parents/teachers need to manage the content of the game, as well as control the time of the game, and be able to test while playing. It's best to be able to write course assignments for the interactive educational world in the simplest possible way.

- [X] Separate play UI from play world management UI
- [X] Control play time and protect children's eyes
- [X] Insert practice while gaming
- [X] Single-player game support different users to use a shared computer
- [ ] Text writing interactive education world lesson plan (TODO: `Text To Game`)

### Comparison with "[Minecraft: Education Edition](https://education.minecraft.net/)" 🎯

| | [Minecraft: Education Edition](https://education.minecraft.net/) | "[Minetest: Education Edition](./)" |
| :------| ------------------------- | ------------- |
| Offline | Can only be used online (must be logged in before entering) | Software that can run offline (no need to register and log in, also available without internet) |
| Type | Paid Commercial Software | Free Open Source Software |
| Target | Only for educational institutions, not open to individuals | Any(include Parents/teachers) are free to use |
| Courses | About 700 online courses | Not Yet |
| Modules | Not supported | Local built-in education-related modules (math, automation, electronic circuits, programming, etc.) and selected modules |
| Self-Hosted service | Not supported | Can be self-hosted local network or Internet game service on linux server |
| Game Time Control | Not Supported | Support Game Time Control |
| Game Content Management | Not Supported | Support Game Content Management |
| Interspersed practice | Not supported | Support interspersed practice during play |

### Download

https://github.com/edu-minetest/minetest/releases/

The Default Key For Parents/Teacher: double seven, double eight and double nine.

### Source

This branch (`Release`) is only created for releases.

To be honest, I don't want to create an independent version of minetest. In order to be able to merge back into the upstream branch at any time, I use independent feature branches for development.
The main feature branch of `Minetest:Edu` is: `edu/builtin`, and a series of sub-feature branches starting with `edu/`.

Branch Description:

* `edu/builtin`: Added student interface and teacher interface
* `edu/settings/binary`: Added support for binary configuration files
* `edu/drawHeader`: fix drawHeader
* `edu/static_spawnpoint`: fix spawn point issue
* `edu/android/client-translation`: fix android default Chinese problem
* `feat/singleplayer-user`: Added multi-users support for single-player game

### LICENSE

* [Minetest](https://minetest.net/): [LGPL2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
* Minetest:Education Edit: [LGPL3](https://www.gnu.org/licenses/lgpl-3.0.html)

[minetest]: https://minetest.net
