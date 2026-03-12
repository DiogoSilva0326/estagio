FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# copy csproj and restore as distinct layers
COPY ["BackendAulaExtra.csproj", "./"]
RUN dotnet restore "./BackendAulaExtra.csproj"

# copy everything else and publish
COPY . .
RUN dotnet publish "BackendAulaExtra.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["dotnet", "BackendAulaExtra.dll"]
