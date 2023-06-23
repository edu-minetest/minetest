LOCAL_PATH := $(call my-dir)/..

#LOCAL_ADDRESS_SANITIZER:=true
#USE_BUILTIN_LUA:=true

include $(CLEAR_VARS)
LOCAL_MODULE := Curl
LOCAL_SRC_FILES := deps/$(APP_ABI)/Curl/libcurl.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libmbedcrypto
LOCAL_SRC_FILES := deps/$(APP_ABI)/Curl/libmbedcrypto.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libmbedtls
LOCAL_SRC_FILES := deps/$(APP_ABI)/Curl/libmbedtls.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libmbedx509
LOCAL_SRC_FILES := deps/$(APP_ABI)/Curl/libmbedx509.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Freetype
LOCAL_SRC_FILES := deps/$(APP_ABI)/Freetype/libfreetype.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Iconv
LOCAL_SRC_FILES := deps/$(APP_ABI)/Iconv/libiconv.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libcharset
LOCAL_SRC_FILES := deps/$(APP_ABI)/Iconv/libcharset.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Irrlicht
LOCAL_SRC_FILES := deps/$(APP_ABI)/Irrlicht/libIrrlichtMt.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Irrlicht-libpng
LOCAL_SRC_FILES := deps/$(APP_ABI)/Irrlicht/libpng.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Irrlicht-libjpeg
LOCAL_SRC_FILES := deps/$(APP_ABI)/Irrlicht/libjpeg.a
include $(PREBUILT_STATIC_LIBRARY)

ifndef USE_BUILTIN_LUA

include $(CLEAR_VARS)
LOCAL_MODULE := LuaJIT
LOCAL_SRC_FILES := deps/$(APP_ABI)/LuaJIT/libluajit.a
include $(PREBUILT_STATIC_LIBRARY)

endif

include $(CLEAR_VARS)
LOCAL_MODULE := OpenAL
LOCAL_SRC_FILES := deps/$(APP_ABI)/OpenAL-Soft/libopenal.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Gettext
LOCAL_SRC_FILES := deps/$(APP_ABI)/Gettext/libintl.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := SQLite3
LOCAL_SRC_FILES := deps/$(APP_ABI)/SQLite/libsqlite3.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Vorbis
LOCAL_SRC_FILES := deps/$(APP_ABI)/Vorbis/libvorbis.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libvorbisfile
LOCAL_SRC_FILES := deps/$(APP_ABI)/Vorbis/libvorbisfile.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libogg
LOCAL_SRC_FILES := deps/$(APP_ABI)/Vorbis/libogg.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Zstd
LOCAL_SRC_FILES := deps/$(APP_ABI)/Zstd/libzstd.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Minetest

LOCAL_CFLAGS += \
	-DJSONCPP_NO_LOCALE_SUPPORT     \
	-DHAVE_TOUCHSCREENGUI           \
	-DENABLE_GLES=1                 \
	-DUSE_CURL=1                    \
	-DUSE_SOUND=1                   \
	-DUSE_LEVELDB=0                 \
	-DUSE_GETTEXT=1                 \
	-DVERSION_MAJOR=${versionMajor} \
	-DVERSION_MINOR=${versionMinor} \
	-DVERSION_PATCH=${versionPatch} \
	-DVERSION_EXTRA=${versionExtra} \
	-DDEVELOPMENT_BUILD=${developmentBuild} \
	$(GPROF_DEF)

ifdef USE_BUILTIN_LUA
	LOCAL_CFLAGS += -DUSE_LUAJIT=0
else
	LOCAL_CFLAGS += -DUSE_LUAJIT=1
endif

ifdef NDEBUG
	LOCAL_CFLAGS += -DNDEBUG=1
endif

ifdef GPROF
	GPROF_DEF := -DGPROF
	PROFILER_LIBS := android-ndk-profiler
	LOCAL_CFLAGS += -pg
endif

LOCAL_C_INCLUDES := \
	../../src                                    \
	../../src/script                             \
	../../lib/gmp                                \
	../../lib/jsoncpp                            \
	../../lib/cereal/include                           \
	deps/$(APP_ABI)/Curl/include                       \
	deps/$(APP_ABI)/Freetype/include/freetype2         \
	deps/$(APP_ABI)/Irrlicht/include                   \
	deps/$(APP_ABI)/Gettext/include                    \
	deps/$(APP_ABI)/Iconv/include                      \
	deps/$(APP_ABI)/OpenAL-Soft/include                \
	deps/$(APP_ABI)/SQLite/include                     \
	deps/$(APP_ABI)/Vorbis/include                     \
	deps/$(APP_ABI)/Zstd/include

ifdef USE_BUILTIN_LUA
	LOCAL_C_INCLUDES += \
		../../lib/lua/src                    \
		../../lib/bitop
else
	LOCAL_C_INCLUDES += deps/$(APP_ABI)/LuaJIT/include
endif

LOCAL_SRC_FILES := \
	$(wildcard ../../src/client/*.cpp)           \
	$(wildcard ../../src/client/*/*.cpp)         \
	$(wildcard ../../src/content/*.cpp)          \
	../../src/database/database.cpp              \
	../../src/database/database-dummy.cpp        \
	../../src/database/database-files.cpp        \
	../../src/database/database-sqlite3.cpp      \
	$(wildcard ../../src/gui/*.cpp)              \
	$(wildcard ../../src/irrlicht_changes/*.cpp) \
	$(wildcard ../../src/mapgen/*.cpp)           \
	$(wildcard ../../src/network/*.cpp)          \
	$(wildcard ../../src/script/*.cpp)           \
	$(wildcard ../../src/script/*/*.cpp)         \
	$(wildcard ../../src/server/*.cpp)           \
	$(wildcard ../../src/threading/*.cpp)        \
	$(wildcard ../../src/util/*.c)               \
	$(wildcard ../../src/util/*.cpp)             \
	../../src/ban.cpp                            \
	../../src/chat.cpp                           \
	../../src/clientiface.cpp                    \
	../../src/collision.cpp                      \
	../../src/content_mapnode.cpp                \
	../../src/content_nodemeta.cpp               \
	../../src/convert_json.cpp                   \
	../../src/craftdef.cpp                       \
	../../src/debug.cpp                          \
	../../src/defaultsettings.cpp                \
	../../src/emerge.cpp                         \
	../../src/environment.cpp                    \
	../../src/face_position_cache.cpp            \
	../../src/filesys.cpp                        \
	../../src/gettext.cpp                        \
	../../src/httpfetch.cpp                      \
	../../src/hud.cpp                            \
	../../src/inventory.cpp                      \
	../../src/inventorymanager.cpp               \
	../../src/itemdef.cpp                        \
	../../src/itemstackmetadata.cpp              \
	../../src/light.cpp                          \
	../../src/lighting.cpp                       \
	../../src/log.cpp                            \
	../../src/main.cpp                           \
	../../src/map.cpp                            \
	../../src/map_settings_manager.cpp           \
	../../src/mapblock.cpp                       \
	../../src/mapnode.cpp                        \
	../../src/mapsector.cpp                      \
	../../src/metadata.cpp                       \
	../../src/modchannels.cpp                    \
	../../src/nameidmapping.cpp                  \
	../../src/nodedef.cpp                        \
	../../src/nodemetadata.cpp                   \
	../../src/nodetimer.cpp                      \
	../../src/noise.cpp                          \
	../../src/objdef.cpp                         \
	../../src/object_properties.cpp              \
	../../src/particles.cpp                      \
	../../src/pathfinder.cpp                     \
	../../src/player.cpp                         \
	../../src/porting.cpp                        \
	../../src/porting_android.cpp                \
	../../src/profiler.cpp                       \
	../../src/raycast.cpp                        \
	../../src/reflowscan.cpp                     \
	../../src/remoteplayer.cpp                   \
	../../src/rollback.cpp                       \
	../../src/rollback_interface.cpp             \
	../../src/serialization.cpp                  \
	../../src/server.cpp                         \
	../../src/serverenvironment.cpp              \
	../../src/serverlist.cpp                     \
	../../src/settings.cpp                       \
	../../src/staticobject.cpp                   \
	../../src/texture_override.cpp               \
	../../src/tileanimation.cpp                  \
	../../src/tool.cpp                           \
	../../src/translation.cpp                    \
	../../src/version.cpp                        \
	../../src/voxel.cpp                          \
	../../src/voxelalgorithms.cpp

# Built-in Lua
ifdef USE_BUILTIN_LUA
	LOCAL_SRC_FILES += \
		../../lib/lua/src/lapi.c \
		../../lib/lua/src/lauxlib.c \
		../../lib/lua/src/lbaselib.c \
		../../lib/lua/src/lcode.c \
		../../lib/lua/src/ldblib.c \
		../../lib/lua/src/ldebug.c \
		../../lib/lua/src/ldo.c \
		../../lib/lua/src/ldump.c \
		../../lib/lua/src/lfunc.c \
		../../lib/lua/src/lgc.c \
		../../lib/lua/src/linit.c \
		../../lib/lua/src/liolib.c \
		../../lib/lua/src/llex.c \
		../../lib/lua/src/lmathlib.c \
		../../lib/lua/src/lmem.c \
		../../lib/lua/src/loadlib.c \
		../../lib/lua/src/lobject.c \
		../../lib/lua/src/lopcodes.c \
		../../lib/lua/src/loslib.c \
		../../lib/lua/src/lparser.c \
		../../lib/lua/src/lstate.c \
		../../lib/lua/src/lstring.c \
		../../lib/lua/src/lstrlib.c \
		../../lib/lua/src/ltable.c \
		../../lib/lua/src/ltablib.c \
		../../lib/lua/src/ltm.c \
		../../lib/lua/src/lundump.c \
		../../lib/lua/src/lvm.c \
		../../lib/lua/src/lzio.c \
		../../lib/bitop/bit.c
endif

# GMP
LOCAL_SRC_FILES += ../../lib/gmp/mini-gmp.c

# JSONCPP
LOCAL_SRC_FILES += ../../lib/jsoncpp/jsoncpp.cpp

LOCAL_STATIC_LIBRARIES += \
	Curl libmbedcrypto libmbedtls libmbedx509 \
	Freetype \
	Iconv libcharset \
	Irrlicht Irrlicht-libpng Irrlicht-libjpeg \
	OpenAL \
	Gettext \
	SQLite3 \
	Vorbis libvorbisfile libogg \
	Zstd
ifndef USE_BUILTIN_LUA
	LOCAL_STATIC_LIBRARIES += LuaJIT
endif
LOCAL_STATIC_LIBRARIES += android_native_app_glue $(PROFILER_LIBS)

LOCAL_LDLIBS := -lEGL -lGLESv1_CM -lGLESv2 -landroid -lOpenSLES -lz

include $(BUILD_SHARED_LIBRARY)

ifdef GPROF
$(call import-module,android-ndk-profiler)
endif
$(call import-module,android/native_app_glue)
