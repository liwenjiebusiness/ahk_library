#include <lib_CORE>
#include <lib_TEST>

Core.init()
(new TestRunner()).run()

Msgbox, % "Tests successful"
ExitApp
