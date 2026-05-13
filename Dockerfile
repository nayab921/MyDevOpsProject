# Step 1: Use official .NET 8 SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY ["MyDevOpsProject.csproj", "./"]
RUN dotnet restore "MyDevOpsProject.csproj"

# Copy the rest of the code and build
COPY . .
RUN dotnet build "MyDevOpsProject.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "MyDevOpsProject.csproj" -c Release -o /app/publish

# Step 2: Use smaller ASP.NET runtime image for the final container
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyDevOpsProject.dll"]