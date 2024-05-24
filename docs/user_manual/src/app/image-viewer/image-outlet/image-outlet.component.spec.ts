import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ImageOutletComponent } from './image-outlet.component';

describe('ImageOutletComponent', () => {
  let component: ImageOutletComponent;
  let fixture: ComponentFixture<ImageOutletComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ImageOutletComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ImageOutletComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
