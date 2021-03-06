#include <lib_CORE>

;; Base class for tests
class TestBase extends ObjectBase {
    ;; Runs the test
    run(){
        throw Exception(this.__class ".run() called but not implemented")
    }
}

;; Class to run all tests
class TestRunner extends TestBase {

    ;; Generate the test script and run it
    run(a_testdir="tests")){

        ; Autogenerated test filename
        l_generated := A_ScriptDir "\__tests_autogen.ahk"
        ; Folder containing all test script files
        l_testdir := a_testdir

        ; Start building the autogenerated test file content
        ; Include default libraries
        l_content := "#include <lib_CORE>`r`n"
        l_content := "#include <lib_TEST>`r`n"
        l_content .= "Core.init()`r`n"
        l_content .= "`r`n"

        ; For each test file, include the test class, which must have the same name as the file
        l_tests := []
        Loop, % l_testdir "\*.ahk"
        {
            l_order := A_index
            l_content.= "#include tests\" A_LoopFileName "`r`n"
            SplitPath, A_LoopFileName,,,, l_noext
            if (RegexMatch(l_noext, "O)([\d]+)_(.*)", l_match)) {
                l_order := l_match[1]
                l_noext := l_match[2]
            }
            l_tests.insert(l_order, l_noext)
        }

        ; For each test loaded, try to run it and save exceptions
        l_content .= "`r`n"
        l_content .= "l_messages := """"`r`n"
        for k, v in l_tests {
            l_content .= "try { `r`n"
            l_content .= "    (new " v "()).run() `r`n"
            l_content .= "    l_messages .= ""[" k " OK ] " v " ``r``n""`r`n"
            l_content .= "} catch l_exc { `r`n"
            l_content .= "    l_messages .= ""[" k " NOK] "" l_exc.what ""()::"" l_exc.line `r`n"
            l_content .= "                  . (l_exc.extra ? "" "" l_exc.extra : """") `r`n"
            l_content .= "                  . "" | "" l_exc.message ""``r``n"" `r`n"
            l_content .= "}`r`n"
        }

        ; Prepare a messagebox with the results
        l_content .= "`r`n"        
        l_content .= "Msgbox,, % ""Test Results"", % l_messages`r`n"
        l_content .= "`r`n"        
        
        ; Then make the autogenerated test script close
        l_content .= "ExitApp"

        ; Write the autogenerated content to file
        FileAppend, % l_content, % l_generated

        ; Run it with the same interpreter which is running this script
        RunWait, % A_AhkPath " " l_generated

        ; Delete the autogenerated file
        FileDelete, % l_generated

        ; Exit the test suite application
        ExitApp

    }

}

