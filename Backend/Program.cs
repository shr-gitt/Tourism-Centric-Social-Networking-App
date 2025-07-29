using System.Text;
using Backend;
using Backend.Data;
using Backend.Models;
using Backend.Services;
using Backend.Services.userPostFeedbacksService;
using Backend.Services.userPostService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MongoDB.Driver;

var builder = WebApplication.CreateBuilder(args);

// Add controllers support
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

// Register Post related services
builder.Services.AddScoped<PostServices>();
builder.Services.AddScoped<CreatePost>();
builder.Services.AddScoped<EditPost>();
builder.Services.AddScoped<UpdateFeedback>();
builder.Services.AddScoped<DeletePost>();
builder.Services.AddScoped<SavePost>();

// Register Feedback related services
builder.Services.AddScoped<FeedbacksService>();
builder.Services.AddScoped<CreateFeedback>();
builder.Services.AddScoped<EditFeedback>();
builder.Services.AddScoped<DeleteFeedback>();
builder.Services.AddScoped<SaveFeedback>();

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

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
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
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "")),
        };
    });

builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
    {
        options.Password.RequiredLength = 6;
        options.Password.RequireNonAlphanumeric = true;
        options.Password.RequireUppercase = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireDigit = true;
    }).AddMongoDbStores<ApplicationUser, ApplicationRole, Guid>(
        builder.Configuration["MongoDbSettings:ConnectionString"],
        builder.Configuration["MongoDbSettings:DatabaseName"])
    .AddDefaultTokenProviders();

builder.Services.AddAuthorization();

var app = builder.Build();

// Seed database on startup (optional, implement SeedData.InitializeAsync as needed)
await using (var scope = app.Services.CreateAsyncScope())
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
}

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

app.MapControllers();

app.Run();
