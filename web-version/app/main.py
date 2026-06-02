from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from .api import router as api_router
import os

app = FastAPI(title="OS Monitor Dashboard")

# Mount static files
static_path = os.path.join(os.path.dirname(__file__), "static")
app.mount("/static", StaticFiles(directory=static_path), name="static")

template_path = os.path.join(os.path.dirname(__file__), "templates")
templates = Jinja2Templates(directory=template_path)

app.include_router(api_router, prefix="/api")

@app.get("/")
async def read_root(request: Request):
    return templates.TemplateResponse(request=request, name="index.html")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
