FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["AlzheimerApp.API/AlzheimerApp.API.csproj", "AlzheimerApp.API/"]
COPY ["AlzheimerApp.Application/AlzheimerApp.Application.csproj", "AlzheimerApp.Application/"]
COPY ["AlzheimerApp.Domain/AlzheimerApp.Domain.csproj", "AlzheimerApp.Domain/"]
COPY ["AlzheimerApp.Infrastructure/AlzheimerApp.Infrastructure.csproj", "AlzheimerApp.Infrastructure/"]
RUN dotnet restore "AlzheimerApp.API/AlzheimerApp.API.csproj"

COPY . .
WORKDIR "/src/AlzheimerApp.API"
RUN dotnet build "AlzheimerApp.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AlzheimerApp.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

EXPOSE 8080 
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "AlzheimerApp.API.dll"]