FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyDevOpsProject.csproj", "./"]
# Restore low memory mode mein
RUN dotnet restore "MyDevOpsProject.csproj" --disable-parallel
COPY . .
# Build aur Publish memory diet par (/m:1 aur shared compilation off)
RUN dotnet build "MyDevOpsProject.csproj" -c Release -o /app/build /m:1 -p:UseSharedCompilation=false
FROM build AS publish
RUN dotnet publish "MyDevOpsProject.csproj" -c Release -o /app/publish /m:1 -p:UseSharedCompilation=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyDevOpsProject.dll"]