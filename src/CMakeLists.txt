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

include_directories(
  ${JCANVAS_INCLUDE_DIRS}
  ${LUA5.3_INCLUDE_DIRS}
)

target_link_libraries(jlua
  ${JCANVAS_LIBRARIES}
  ${LUA5.3_LIBRARIES}
  )
