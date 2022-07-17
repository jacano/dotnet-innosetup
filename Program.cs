using System.Reflection;

var arguments = System.Environment.CommandLine;
Console.WriteLine(arguments);
var end = ".dll ";
arguments = arguments.Substring(arguments.IndexOf(end)+end.Length);
Console.WriteLine(arguments);

var p = System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
{
    FileName = Path.Combine(Assembly.GetExecutingAssembly().Location, "..", "is", "ISCC.exe"),
    Arguments = arguments,
    CreateNoWindow = false,
    UseShellExecute = false,
});
p.WaitForExit();
return p.ExitCode;
