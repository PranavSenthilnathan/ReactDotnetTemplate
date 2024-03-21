pwd 

$testAppDir = "testing\ReactApp2"
pushd $PSScriptRoot
try {
    dotnet new install "working\content\reactapp.client" --force
    if (test-path $testAppDir) {
        rm -r -fo $testAppDir
    }

    mkdir $testAppDir
    pushd $testAppDir
    try {
        dotnet new sln

        dotnet new webapi -o ReactApp.Server
        dotnet sln add ReactApp.Server/ReactApp.Server.csproj

        dotnet new ReactTemplate -o reactapp.client
        dotnet sln add reactapp.client/reactapp.client.esproj

        dotnet add ReactApp.Server/ReactApp.Server.csproj reference reactapp.client/reactapp.client.esproj
        dotnet add ReactApp.Server/ReactApp.Server.csproj package Microsoft.AspNetCore.SpaProxy
        
        # Note that the following msbuild properties should be in the csproj and environment variable in the launchSettings.json
        # but the current webapi template does not support it 
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