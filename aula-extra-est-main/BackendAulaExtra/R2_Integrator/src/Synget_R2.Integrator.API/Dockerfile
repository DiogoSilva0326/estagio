FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY Synget_R2.Integrator.sln ./
COPY Synget_R2.Integrator/*.csproj ./Synget_R2.Integrator/
COPY Synget_R2.Integrator.API/*.csproj ./Synget_R2.Integrator.API/

RUN dotnet restore "Synget_R2.Integrator.API/Synget_R2.Integrator.API.csproj"

COPY . .
WORKDIR /src/Synget_R2.Integrator.API
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish ./

EXPOSE 80

ENTRYPOINT ["dotnet", "Synget_R2.Integrator.API.dll"]