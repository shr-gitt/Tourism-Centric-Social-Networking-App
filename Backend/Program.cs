using System.Text;
using Backend;
using Backend.Data;
using Backend.Models;
using Backend.Services;
using Backend.Services.userAccount;
using Backend.Services.userPostService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MongoDB.Bson;
using MongoDB.Driver;

var builder = WebApplication.CreateBuilder(args);

// Add controller support
builder.Services.AddControllers();

// Configure MongoDB settings from appsettings.json
builder.Services.Configure<MongoDbSettings>(
    builder.Configuration.GetSection("MongoDbSettings"));

// Register MongoDB client singleton
builder.Services.AddSingleton<IMongoClient>(sp =>
{
    var settings = builder.Configuration.GetSection("MongoDbSettings").Get<MongoDbSettings>();
    return new MongoClient(settings.ConnectionString);
});

builder.Services.AddScoped<IMongoCollection<Post>>(sp =>
{
    var settings = sp.GetRequiredService<IOptions<MongoDbSettings>>().Value;
    var client = sp.GetRequiredService<IMongoClient>();
    var database = client.GetDatabase(settings.DatabaseName);
    return database.GetCollection<Post>(settings.PostsCollectionName);
});

builder.Services.AddScoped<IMongoCollection<Feedback>>(sp =>
{
    var settings = sp.GetRequiredService<IOptions<MongoDbSettings>>().Value;
    var client = sp.GetRequiredService<IMongoClient>();
    var database = client.GetDatabase(settings.DatabaseName);
    return database.GetCollection<Feedback>(settings.FeedbacksCollectionName);
});

// Register data contexts
builder.Services.AddScoped<PostsContext>();
builder.Services.AddScoped<FeedbacksContext>();
builder.Services.AddScoped<AccountContext>();

//Register Account related services
builder.Services.AddScoped<AccountServices>();
builder.Services.AddScoped<IEmailSender, AuthMessageSender>();
builder.Services.AddScoped<UploadImage>();

// Register Post related services
builder.Services.AddScoped<PostServices>();

// Register Feedback related services
builder.Services.AddScoped<FeedbacksService>();

// Configure Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = "My API", 
        Version = "v1",
        Description = "API for managing users, posts and feedbacks."
    });
    c.EnableAnnotations();
   
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: 'Bearer {token}'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// Configure CORS to allow all origins, headers and methods (customize as needed)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

builder.Services.AddAuthentication(options =>
    {
        options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "")),
            NameClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier",
            RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
        };
    })
    .AddGoogle(googleOptions =>
    {
        googleOptions.ClientId = builder.Configuration["Authentication:Google:ClientId"];
        googleOptions.ClientSecret = builder.Configuration["Authentication:Google:ClientSecret"];
    });

builder.Services
    .AddIdentity<ApplicationUser, ApplicationRole>(options =>
    {
        options.Password.RequiredLength = 6;
        options.Password.RequireNonAlphanumeric = true;
        options.Password.RequireUppercase = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireDigit = true;

        options.Tokens.PasswordResetTokenProvider = "TokenProvider";
        options.Tokens.EmailConfirmationTokenProvider = "TokenProvider";
    })
    .AddTokenProvider<TokenProvider<ApplicationUser>>("TokenProvider")
    .AddUserManager<CustomUserManager>()
    .AddMongoDbStores<ApplicationUser, ApplicationRole, ObjectId>(
        builder.Configuration["MongoDbSettings:ConnectionString"],
        builder.Configuration["MongoDbSettings:DatabaseName"])
    .AddDefaultTokenProviders();

builder.Services.AddAuthorization();

var app = builder.Build();

// Seed database on startup (optional, implement SeedData.InitializeAsync as needed)
/*await using (var scope = app.Services.CreateAsyncScope())
{
    var services = scope.ServiceProvider;
    try
    {
        await SeedData.InitializeAsync(services);
        Console.WriteLine("Database seeding complete.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error seeding data: {ex.Message}");
    }
}*/

// Global error handler for production environment
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler(errorApp =>
    {
        errorApp.Run(async context =>
        {
            context.Response.StatusCode = 500;
            context.Response.ContentType = "application/json";

            var errorResponse = new
            {
                message = "An unexpected error occurred. Please try again later."
            };
            await context.Response.WriteAsJsonAsync(errorResponse);
        });
    });

    app.UseHsts();
    // app.UseHttpsRedirection(); // Enable if you want to enforce HTTPS
}
else
{
    // Enable developer-friendly middleware during development
    app.UseDeveloperExceptionPage();
}

// Enable Swagger UI middleware at root URL
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
    c.RoutePrefix = string.Empty; // Swagger UI served at "/"
});

// app.UseHttpsRedirection(); // Uncomment if HTTPS enforcement is desired

app.UseRouting();

// Apply the CORS policy globally
app.UseCors("AllowAll");

app.UseAuthentication();

app.UseAuthorization();

app.UseStaticFiles();

app.MapControllers();

// Log all routes after mapping
var routeBuilder = new StringBuilder();
foreach (var dataSource in app.Services.GetRequiredService<EndpointDataSource>().Endpoints)
{
    if (dataSource is RouteEndpoint route)
    {
        routeBuilder.AppendLine(route.RoutePattern.RawText);
    }
}
Console.WriteLine("Registered Routes:\n" + routeBuilder);

app.Run();
