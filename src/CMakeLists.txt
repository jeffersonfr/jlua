cmake_minimum_required (VERSION 3.0)

include_directories(
  ${JLIBCPP_INCLUDE_DIRS}
  ${LUA5.3_INCLUDE_DIRS}
)

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
  ${JLIBCPP_LIBRARIES}
  ${LUA5.3_LIBRARIES}
  )

add_definitions(${JLIBCPP_CFLAGS})
add_definitions(${LUA5.3_CFLAGS})

