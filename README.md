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

- [X] Separates game interface into gameplay and password-protected content management screens for parents/teachers.
- [X] Control of gameplay time to protect children's eyesight
- [X] Periodically presents educational exercises to improve knowledge while playing
- [X] Single-player game support different users to use a shared computer
- [ ] Write interactive educational world courses using approximate natural language text outside of the game(TODO: `Text To Game`)

To enhance the learning experience, we developed the [Quiz player challenge mod](https://github.com/edu-minetest/quiz/) to implement periodic exercises during gameplay, ensuring that children are consistently practicing and learning.

To make it easier for parents and teachers to manage game content, we directly modified the interface of Minetest by separating the student game interface (gameplay) from the teacher interface (manage game content). This makes it easier for teachers to manage the game and customize it for their students.

In addition, Minetest: Education Edition comes with a variety of built-in educational mods, including mods for mathematics, automation, electronic circuits, programming, and more. These mods provide a wealth of educational content that can be used to enhance learning in various subjects.

Looking to the future, we plan to develop a specification for a near-natural language text format, which will be used to write interactive course content. The course content written in this format can be converted into Minetest game worlds using a tool that we'll develop. This means that teachers will only need to maintain the course content text, rather than the game world itself.

This approach will make it easier for teachers and parents to collaborate on course content, as they can review and revise the text-based course content without having to deal with the complexities of building and maintaining a game world.

The game world is engaging and encourages children to keep practicing if they want to continue playing. With [Minetest: Education Edition](./), children can explore and learn in a fun and interactive way, with the freedom to customize their learning experience to fit their interests and needs.

We hope that by releasing this open-source project, more people can benefit from the learning opportunities presented by [Minetest: Education Edition](./).

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
| Interspersed practice | Not supported | Support periodic practices during gameplay |

---

- [Minecraft:Education Edit](https://education.minecraft.net/)：
  - Essentially an online service (must be logged in before entering)
  - Commercial software
    - No modifications or improvements can be made to the software itself
  - Only for educational institutions, not open to individuals (individuals must rely on institutions)
  - 700 standards-compliant lessons built into the in-game library (not builtin, in-app download required)
  - Course writing hassle: essentially built in-game
  - ✘ No support self-hosted local network or Internet services (services can only be provided in the game)
  - ✘ No support self-hosted local network or Internet services (services can only be provided in the game)
  - ✘ No support controlling game time
  - ✘ No support game content management
  - ✘ periodic practices in game is not supported
- Minetest:Education Edit：
  - The essence is a software that can run offline (no registration required, no network is also available)
  - Free (free) open source software
    - The software can be modified or improved under the premise of following its open source copyright license ([LGPL3](https://www.gnu.org/licenses/lgpl-3.0.zh-cn.html))
  - ✔ Anyone institutions/individuals, All (include Parents/Teachers) are free to use
  - ✔ Modular architecture design
  - ✔ Local built-in education related modules (mathematics, automation, electronic circuits, programming, etc.) and selected modules.
  - ✘ No courses for now, you need to create your own
  - ✔ Support local network or Internet game service on Linux server for multiplayer games (minetestserver)
  - ✔ Support control game time
  - ✔ Support game content management
  - ✔ Support periodic practices in-game

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
* `fix/trusted_mod_io`: This security patch determines a function's access rights by checking which mod ultimately initiated the execution of the script function.
  * Note: You should disable Lua's tail call optimization to address the issue of Lua call stack information being lost.
  * Here is my code to [disable Lua's tail call optimization](https://github.com/edu-minetest/LuaJIT/tree/feat/tailcall)
  * When a regular mod calls a function of a trusted mod, the privilege should not be elevated.
  * When a trusted mod calls a function of a regular mod, the privilege should not downgrade.
* `rubenwardy-world_independent_common_data`: Modified from [Add world-independent storage directory for mods](https://github.com/minetest/minetest/pull/12315)
  * `minetest.get_mod_data_path()`: add optional `mod_name` argument.
  * `minetest.get_mod_data_path(mod_name)` can be used in `mainmenu`
  * The `mod_data/[mod_name]/` directory is typically writable by its mod owner and readable by others.
  * already merged the `fix/trusted_mod_io` branch.

### LICENSE

* [Minetest](https://minetest.net/): [LGPL2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
* Minetest:Education Edit: [LGPL3](https://www.gnu.org/licenses/lgpl-3.0.html)

[minetest]: https://minetest.net
