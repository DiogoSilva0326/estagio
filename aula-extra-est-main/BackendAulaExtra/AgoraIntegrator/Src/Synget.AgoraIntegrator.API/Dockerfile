FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# copy csproj and restore as distinct layers
COPY *.sln ./
COPY Synget.AgoraIntegrator.API/*.csproj ./Synget.AgoraIntegrator.API/
COPY Synget.AgoraIntegrator/*.csproj ./Synget.AgoraIntegrator/
COPY Synget.ChatIntegrator/*.csproj ./Synget.ChatIntegrator/

RUN dotnet restore "Synget.AgoraIntegrator.API/Synget.AgoraIntegrator.API.csproj"

# copy everything else and publish
COPY . .
WORKDIR /src/Synget.AgoraIntegrator.API
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish ./

# Expose the port configured via ASPNETCORE_URLS (default to 80 inside container)
ENV ASPNETCORE_URLS=http://+:80
ENV DOTNET_RUNNING_IN_CONTAINER=true

ENTRYPOINT ["dotnet", "Synget.AgoraIntegrator.API.dll"]
