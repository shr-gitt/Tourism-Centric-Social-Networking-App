namespace Backend.Services.userPostService;

public class UploadImage
{
    public string Upload(IFormFile file)
    {
        List<string> validExtensions = new List<string>() { ".jpg", ".jpeg", ".png", ".gif" };
        string extension = Path.GetExtension(file.FileName).ToLower();
        if (!validExtensions.Contains(extension))
        {
            return $"Extension is not valid({string.Join(',', validExtensions)})";
        }

        string fileName = Guid.NewGuid().ToString() + extension;
        string path = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Images");
        //string path = Path.Combine("wwwroot", "Images");

        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        string fullPath = Path.Combine(path, fileName);
        using (var fileStream = new FileStream(fullPath, FileMode.Create))
        {
            file.CopyTo(fileStream);
        }

        return "/Images/" + fileName; 
    }
}
