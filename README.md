# Rench.Net

Easily download files from a GitHub `toolbox/tools` repository folder & add them to your Visual Studio project using [Nuget](https://www.nuget.org/packages/Rench/) and the [Package Manager Console](http://docs.nuget.org/docs/start-here/using-the-package-manager-console).

## GitHub Toolbox

To use Rench.Net:

- Create a public Github repository called `toolbox`.
- Create a `tools` directory under the `toolbox` repository 
- Add any tools (files) you wish to make available for easy download and install

Of course, Rench.Net can also download & install from any existing GitHub user account, as long as it contains a public `toolbox/tools` repository folder.

## Instructions

1. Install the current version of Rench.Net using the [Package Manager Console](http://docs.nuget.org/docs/start-here/using-the-package-manager-console)
2. Once installed, use the command `Get-Tool` to specify a GitHub user account for which to select files from the `toolbox/tools` repository (see above).
3. Select an available file from the prompt
4. Rench will then automatically download & add the file to your default project. (You can select another project by changing the value of the `Default project` in the drop-down in the Package Manager Console window. 
 
For example:

	 PM> Install-Package Rench
	 Successfully installed 'Rench 1.0.1'.
	 Successfully added 'Rench 1.0.1' to ConsoleApplication1.

	 PM> Get-Tool chrismelinn

	 Choose a tool:

	 	 [0] rench_test.txt

	 Enter Tool # to download: 0

	 Downloading:

	 	 Tool: rench_test.txt 

	 	 To Location: c:\users\chrismelinn\VSProjects\ConsoleApplication1\ConsoleApplication1\rench_test.txt 

	 	 Adding to default project: ConsoleApplication1 

	 PM> 


## Thanks to Micah Cooper
This project was ported from & inspired by [Rench](https://github.com/mrmicahcooper/rench), a ruby gem project by [Micah Cooper](https://github.com/mrmicahcooper). You can read more about his project [here](http://hashrocket.com/blog/posts/put-your-programming-tools-in-a-toolbox).