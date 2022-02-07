cmake_minimum_required (VERSION 3.0)

add_executable(jlua
		display.cpp
    canvas.cpp
    font.cpp
		event.cpp
    mixer.cpp
		utils.cpp
    jlua.cpp
    main.cpp
  )

target_link_libraries(jlua
  PRIVATE
    PkgConfig::jCanvas
    PkgConfig::Lua5.3
  )
