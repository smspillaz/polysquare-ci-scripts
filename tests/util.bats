#!/usr/bin/env bats
# /tests/util.bats
#
# Tests for the utility functions in travis/
#
# See LICENCE.md for Copyright information

load polysquare_ci_scripts_helper
source "${POLYSQUARE_TRAVIS_SCRIPTS}/util.sh"

@test "Calling print error prints bangs then args" {
    run polysquare_print_error "arg1 arg2 arg3"
    [ "${lines[0]}" = "!!! arg1 arg2 arg3" ]
}

@test "Print description after fat arrow on first task level" {
    function toplevel_only_task_function {
        true
    }

    run polysquare_task "Description" toplevel_only_task_function

    [ "${lines[0]}" = "=> Description" ]
}

@test "Print description after dots and one indent on second task level" {
    function toplevel_only_task_function {
        function secondary_task_level {
            printf "\n"
        }

        polysquare_task "Secondary description" secondary_task_level
    }

    run polysquare_task "Description" toplevel_only_task_function

    [ "${lines[1]}" = "    ... Secondary description" ]
}

@test "Command output on secondary task level is indented on third" {
    function toplevel_only_task_function {
        function secondary_task_level {
            polysquare_monitor_command_status status echo "output"
        }

        polysquare_task "Secondary description" secondary_task_level
    }

    run polysquare_task "Description" toplevel_only_task_function

    [ "${lines[2]}" = "        output" ]
}

@test "Print description after dots and two indents on third task level" {
    function toplevel_only_task_function {
        function secondary_task_level {
            function third_task_level {
                printf "\n"
            }

            polysquare_task "Tertiary description" third_task_level
        }

        polysquare_task "Secondary description" secondary_task_level
    }

    run polysquare_task "Description" toplevel_only_task_function

    [ "${lines[2]}" = "        ... Tertiary description" ]
}

@test "Repeat switch for list" {
    polysquare_repeat_switch_for_list rval "-x" one two three

    [ "${rval}" = "-x one -x two -x three" ]
}

@test "Repeat switch for list does not produce switch with no value" {
    polysquare_repeat_switch_for_list rval "-x" ""
    [ "${rval}" = "" ]
}

@test "Single find extension argument" {
    polysquare_get_find_extensions_arguments rval sh
    [ "${rval}" = " -name \"*.sh\"" ]
}

@test "Output of find command can be sorted" {
    local tempdir=$(mktemp -d "/tmp/psq-find-output.XXXXXX")
    mkdir -p "${tempdir}/a"
    mkdir -p "${tempdir}/b"
    touch "${tempdir}/a/1"
    touch "${tempdir}/a/2"
    touch "${tempdir}/b/1"
    touch "${tempdir}/b/2"
    touch "${tempdir}/c"

    run polysquare_sorted_find "${tempdir}" -type f

    [ "${lines[0]}" == "${tempdir}/c" ]
    [ "${lines[1]}" == "${tempdir}/a/1" ]
    [ "${lines[2]}" == "${tempdir}/a/2" ]
    [ "${lines[3]}" == "${tempdir}/b/1" ]
    [ "${lines[4]}" == "${tempdir}/b/2" ]
}

@test "Compare string versions less" {
    [ "$(polysquare_numeric_version 3.1.2)" -lt \
      "$(polysquare_numeric_version 4.1.3)" ]
}

@test "Compare string versions greater" {
    [ "$(polysquare_numeric_version 4.1.2)" -gt \
      "$(polysquare_numeric_version 2.1.3)" ]
}

@test "Compare string versions equal" {
    [ "$(polysquare_numeric_version 3.1.2)" -eq \
      "$(polysquare_numeric_version 3.1.2)" ]
}

@test "Compare extracted version less" {
    [ "$(echo 3.1.2 | polysquare_extract_numeric_version)" -lt \
      "$(echo 4.1.3 | polysquare_extract_numeric_version)" ]
}

@test "Monitoring command status with true return value" {
    run print_returned_args_on_newlines \
        polysquare_monitor_command_status \
        1 \
        rval \
        true

    [ "${lines[0]}" = "0" ]
}

@test "Monitoring command status with false return value" {
    run print_returned_args_on_newlines \
        polysquare_monitor_command_status \
        1 \
        rval \
        false

    [ "${lines[0]}" = "1" ]
}

@test "Monitoring command status prints initial newline on output" {
    run polysquare_task "Task" \
        polysquare_monitor_command_status status echo "output"

    [ "${lines[1]}" = "    output" ]
}

@test "Monitoring command status no newline on no output" {
    run polysquare_task "Task" \
        polysquare_monitor_command_status status \
            polysquare_task "Secondary" true

    [ "${lines[1]}" = "    ... Secondary" ]
}

@test "Monitoring command output prints dots whilst command executing" {
    export POLYSQUARE_DOT_SLEEP=1
    unset _POLYSQUARE_DONT_PRINT_DOTS
    run polysquare_monitor_command_output status output sleep 3

    # Restore env
    unset POLYSQUARE_DOT_SLEEP
    export _POLYSQUARE_DONT_PRINT_DOTS=1

    # Number of dots should be ${seconds_sleep} - 1, since
    # we start printing dots a little bit after we start sleeping.
    [ "${output}" = ".." ]
}

@test "Monitoring command output to standard output" {
    run print_returned_args_on_newlines \
        polysquare_monitor_command_output \
        2 \
        command_status \
        command_output \
        echo stdout

    command_output=$(cat "${lines[1]}")

    [ "${command_output}" = "stdout" ]
}

@test "Command with status printed when reporting failures and continuing" {
    run polysquare_report_failures_and_continue \
        command_status \
        false

    [ "${lines[0]}" = "!!! Subcommand false failed with 1" ]
}

@test "Successful status returned when reporting failures and continuing" {
    run print_returned_args_on_newlines \
        polysquare_report_failures_and_continue \
        1 \
        command_status \
        true

    command_status="${lines[0]}"

    [ "${command_status}" = "0" ]
}

@test "Fail status returned when reporting failures and continuing" {
    run print_returned_args_on_newlines \
        polysquare_report_failures_and_continue \
        1 \
        command_status \
        false

    command_status="${lines[0]}"

    [ "${command_status}" = "1" ]
}

@test "Successful status returned when noting failures and continuing" {
    run print_returned_args_on_newlines \
        polysquare_note_failure_and_continue \
        1 \
        command_status \
        true

    command_status="${lines[0]}"

    [ "${command_status}" = "0" ]
}

@test "Fail status returned when noting failures and continuing" {
    run print_returned_args_on_newlines \
        polysquare_note_failure_and_continue \
        1 \
        command_status \
        false

    command_status="${lines[0]}"

    [ "${command_status}" = "1" ]
}

@test "Exit with fatal error when reporting a failure" {
    run polysquare_fatal_error_on_failure \
        false

    [ "${status}" = "1" ]
}

@test "Exit with success when no fatal errors to be reported" {
    polysquare_fatal_error_on_failure true
    polysquare_fatal_error_on_failure true
}

@test "Show failing subcommand and status when exiting on fatal error" {
    run polysquare_fatal_error_on_failure \
        false

    [ "${lines[0]}" = "!!! Subcommand false failed with 1" ]
}

@test "Run subsequent command if another is unavailable" {
    run polysquare_run_if_unavailable __definitely_unavailable \
        echo "true"

    echo "${output}"

    [ "${lines[0]}" = "true" ]
}

@test "Dont run subsequent command if another is available" {
    run polysquare_run_if_unavailable bash \
        echo "true"

    [ "${output}" = "" ]
}