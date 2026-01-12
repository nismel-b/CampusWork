
import { GoogleGenAI } from "@google/genai";

// Fix: Always use process.env.API_KEY directly for SDK initialization
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

export const getProjectHelp = async (title: string, currentDesc: string) => {
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `User is building a university project titled "${title}". 
                 Current description: "${currentDesc}". 
                 Suggest 3 improvements to make the description more professional and detailed. 
                 Provide a "Revised Version" at the end. Keep it in French if the input is French.`
    });
    return response.text;
  } catch (error) {
    console.error("Gemini Error:", error);
    return "Désolé, l'assistant IA n'est pas disponible pour le moment.";
  }
};
