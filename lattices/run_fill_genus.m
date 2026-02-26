// This file is used to find all of the representatives in a positive definite genus, along with some difficult to compute quantities about the genus itself.
// Usage: magma -b label:=foo run_fill_genus.m
// Batch: magma -b labels:=foo:bar:baz run_fill_genus.m
// Options: timeout:=N (default 60, seconds per label)
//          done:=1 (print DONE sentinel on completion, for wrapper scripts)
//
// Parallel across servers:
//   xargs -n 100 < genera_todo.txt | tr ' ' ':' > genera_todo_chunked.txt
//   parallel --sshloginfile servers.txt --joblog jobs.log --eta --resume \
//     'cd ~/projects/k3s-lmfdb/lattices && magma -b labels:={} verbose:=0 run_fill_genus.m' \
//     :::: genera_todo_chunked.txt > output.txt
//
// Errors are prefixed with "ERROR: label: ..."
// Extract retry list: grep '^ERROR:' output.txt | cut -d: -f2 | tr -d ' ' > genera_failed.txt

SetQuitOnError(true);
AttachSpec("lattices.spec");

if not assigned verbose then verbose := "0"; end if;
SetVerbose("FillGenus", StringToInteger(verbose));

if not assigned timeout then timeout := "60"; end if;
timeout := StringToInteger(timeout);

if not assigned done then done := "0"; end if;
done := StringToInteger(done) ne 0;

if assigned labels then
    label_list := Split(labels, ":");
else
    label_list := [label];
end if;

procedure() // forcing magma to read the full input before forking
failed := [];
for l in label_list do
    try
        FillGenus(l : timeout := timeout);
    catch e
        printf "ERROR: %o: %o\n", l, e;
        Append(~failed, l);
    end try;
end for;

if #failed gt 0 then
    if done then printf "DONE: %o failures\n", #failed; end if;
    exit 1;
end if;
if done then printf "DONE\n"; end if;
exit 0;
end procedure();
