pwd 

$testAppDir = "testing\ReactApp"
pushd $PSScriptRoot
try {
    dotnet new install "working\content\reactapp.client" --force
    if (test-path $testAppDir) {
        rm -r -fo $testAppDir
    }

    mkdir $testAppDir
    pushd $testAppDir
    try {
        # Asks for dotnet CLI in combined template proposal:
        # - allow adding P2P reference in/to any of the subprojects
        # - allow adding package references if there isn't already a way to do so
        # - top level variables passable into the subprojects (this is already in Chet's proposal). In our case we need this for ports.

        dotnet new sln

        dotnet new webapi -o ReactApp.Server
        dotnet sln add ReactApp.Server/ReactApp.Server.csproj

        dotnet new ReactTemplate -o reactapp.client
        dotnet sln add reactapp.client/reactapp.client.esproj

        dotnet add ReactApp.Server/ReactApp.Server.csproj reference reactapp.client/reactapp.client.esproj
        dotnet add ReactApp.Server/ReactApp.Server.csproj package Microsoft.AspNetCore.SpaProxy
        
        # Note that the following msbuild properties should be in the csproj and environment variable in the launchSettings.json
        # but the current webapi template does not support it 
        # TODO To also get this working in VS, the backend port needs to be passed into the JSPS project. The webapi has a parameter
        # for it so it should be generated at the sln level and passed down to both the backend and frontend projects in dotnet new
        echo `
"Run using:
    `$env:ASPNETCORE_HOSTINGSTARTUPASSEMBLIES=`"Microsoft.AspNetCore.SpaProxy`" ; ``
    dotnet run --project $PSScriptRoot\$testAppDir\ReactApp.Server ``
        --launch-profile https ``
        --property:SpaRoot=..\reactapp.client ``
        --property:SpaProxyLaunchCommand=`"npm run dev`" ``
        --property:SpaProxyServerUrl=https://localhost:5173"
        echo "Unset the environment variable using: Remove-Item Env:ASPNETCORE_HOSTINGSTARTUPASSEMBLIES"
    }
    finally {
        popd
    }
}
finally {
    popd
}