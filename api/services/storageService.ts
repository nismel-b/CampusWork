
/**
 * CLOUDINARY STORAGE SERVICE
 * Firebase-Storage is not used. Files are hosted on Cloudinary.
 * URLs are stored in Firestore project/user documents.
 */

const delay = (ms: number = 500) => new Promise(res => setTimeout(res, ms));

export const storageService = {
  // Cloudinary Upload
  upload: async (file: File, folder: string = 'campuswork'): Promise<string> => {
    await delay(1200);
    console.log(`Cloudinary: Uploading ${file.name} to folder /${folder}`);
    // Future: Using Cloudinary Upload API
    return `https://res.cloudinary.com/campuswork/image/upload/v1/${folder}/${file.name}`;
  },

  // Delete from Cloudinary
  delete: async (publicId: string): Promise<void> => {
    await delay();
    console.log(`Cloudinary: Removing asset ${publicId}`);
  }
};
