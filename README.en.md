## Minetest:Education Edit

Minetest:Education Edit is an open source interactive educational application based on [Minetest][Minetest] (an open source voxel game engine).

[minetest]: https://minetest.net

Parents/teachers need to manage the content of the game, as well as control the time of the game, and be able to test while playing. It's best to be able to write course assignments for the interactive educational world in the simplest possible way.

- [X] Separate play UI from play world management UI
- [X] Control play time and protect children's eyes
- [X] Insert practice while gaming
- [X] Single-player game support different users to use a shared computer
- [ ] Text writing interactive education world lesson plan (TODO: `Text To Game`)

### Download

https://github.com/edu-minetest/minetest/releases/

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
